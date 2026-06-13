//
//  VoqalSentrySink.swift
//  VoqalSentry
//
//  Maps Voqal diagnostic events onto Sentry: trace frames → transactions/spans,
//  info/debug/warning → breadcrumbs, errors → captured exceptions/messages with
//  the full context (user, tenant, environment, device) and the breadcrumb trail
//  leading up to the failure.
//

import Foundation
import Sentry
import VoqalSDK

final class VoqalSentrySink: VoqalLogSink {
    /// Live Sentry spans keyed by our trace span id. Accessed only from the
    /// single-threaded VoqalLog queue, but guarded for safety.
    private var spans: [String: Span] = [:]
    private let lock = NSLock()

    func record(_ event: VoqalLogEvent) {
        if let userId = VoqalDiagnosticsContext.shared.userId {
            let user = User(); user.userId = userId
            SentrySDK.setUser(user)
        }
        if let frame = event.trace {
            handleTrace(frame, metadata: event.metadata)
            return
        }
        switch event.level {
        case .debug, .info, .warning:
            addBreadcrumb(event)
        case .error:
            captureError(event)
        }
    }

    /// Tags lifted from the ambient context so events are searchable in Sentry by
    /// who/tenant/environment/device.
    private func tags(from metadata: [String: String]) -> [String: String] {
        var out: [String: String] = [:]
        for key in ["environment", "tenant", "session_id", "sdk_version",
                    "device_model", "os_version", "locale"] {
            if let value = metadata[key] { out[key] = value }
        }
        return out
    }

    // MARK: - Breadcrumbs

    private func addBreadcrumb(_ event: VoqalLogEvent) {
        let crumb = Breadcrumb()
        crumb.level = event.level.sentryLevel
        crumb.category = event.category
        crumb.message = event.message
        crumb.data = event.metadata
        SentrySDK.addBreadcrumb(crumb)
    }

    // MARK: - Errors

    private func captureError(_ event: VoqalLogEvent) {
        // Replay the trail so the captured error carries what they were doing.
        for crumb in event.breadcrumbs ?? [] {
            let bc = Breadcrumb()
            bc.level = crumb.level.sentryLevel
            bc.category = crumb.category
            bc.message = crumb.message
            SentrySDK.addBreadcrumb(bc)
        }
        // Build the event explicitly (capture(event:) is public across the SPM and
        // CocoaPods static variants; the scope-block capture overloads are not).
        let sentryEvent = Event(level: .error)
        sentryEvent.message = SentryMessage(formatted: event.message)
        var eventTags = tags(from: event.metadata)
        eventTags["category"] = event.category
        sentryEvent.tags = eventTags
        if let userId = VoqalDiagnosticsContext.shared.userId {
            let user = User(); user.userId = userId
            sentryEvent.user = user
        }
        if let error = event.error {
            sentryEvent.error = error as NSError
        }
        SentrySDK.capture(event: sentryEvent)
    }

    // MARK: - Tracing

    private func handleTrace(_ frame: VoqalTraceFrame, metadata: [String: String]) {
        switch frame.phase {
        case .start:
            let span: Span
            if frame.isTransaction {
                span = SentrySDK.startTransaction(name: frame.op, operation: frame.op)
            } else if let parentId = frame.parentSpanId, let parent = lookup(parentId) {
                span = parent.startChild(operation: frame.op, description: frame.description)
            } else {
                span = SentrySDK.startTransaction(name: frame.op, operation: frame.op)
            }
            for (key, value) in frame.data { span.setData(value: value, key: key) }
            store(frame.spanId, span)
        case .finish:
            guard let span = remove(frame.spanId) else { return }
            for (key, value) in frame.data { span.setData(value: value, key: key) }
            span.finish(status: frame.status.sentryStatus)
        }
    }

    private func store(_ id: String, _ span: Span) { lock.lock(); spans[id] = span; lock.unlock() }
    private func lookup(_ id: String) -> Span? { lock.lock(); defer { lock.unlock() }; return spans[id] }
    private func remove(_ id: String) -> Span? { lock.lock(); defer { lock.unlock() }; return spans.removeValue(forKey: id) }
}

// MARK: - Mappings

private extension VoqalLogLevel {
    var sentryLevel: SentryLevel {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .warning
        case .error: return .error
        }
    }
}

private extension Optional where Wrapped == VoqalSpanStatus {
    var sentryStatus: SentrySpanStatus {
        switch self {
        case .some(.ok): return .ok
        case .some(.failed): return .internalError
        case .some(.cancelled): return .cancelled
        case .none: return .undefined
        }
    }
}
