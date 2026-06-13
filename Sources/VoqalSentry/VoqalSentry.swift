//
//  VoqalSentry.swift
//  VoqalSentry — the Sentry bridge for the Voqal SDK.
//
//  Links sentry-cocoa and forwards everything the core SDK reports (errors,
//  traces, breadcrumbs, who/which-device/which-tenant context) into Sentry.
//  The core has NO Sentry dependency; this product is the only place sentry-cocoa
//  is linked, so integrators who don't want it never pull it in.
//
//  Usage (one line at app launch, before VoqalSDKManager.setup):
//      VoqalSentry.enable()                       // uses the baked Voqal DSN
//      VoqalSentry.enable(options: .init(dsn:))   // or your own Sentry project
//

import Foundation
import Sentry
import VoqalSDK

public enum VoqalSentry {

    /// Register the Sentry reporter so `VoqalSDKManager.setup` starts it
    /// automatically. Call once at launch. Idempotent.
    public static func enable(options: VoqalObservabilityOptions = .init()) {
        VoqalObservability.registerInstaller { resolved in
            start(resolved)
        }
        // If setup already ran (installer registered late), start now.
        VoqalObservability.startIfConfigured(options)
    }

    /// Start Sentry immediately with explicit options (alternative to `enable`).
    public static func start(_ options: VoqalObservabilityOptions) {
        guard let dsn = options.effectiveDSN else { return }
        SentrySDK.start { config in
            config.dsn = dsn
            config.environment = options.environment ?? "unknown"
            config.tracesSampleRate = NSNumber(value: options.tracesSampleRate)
            config.enableAutoSessionTracking = true
            if options.scrubPII {
                config.beforeSend = { event in PIIScrubber.scrub(event); return event }
                config.beforeBreadcrumb = { crumb in PIIScrubber.scrub(crumb); return crumb }
            }
        }
        VoqalLog.shared.addSink(VoqalSentrySink())
    }
}
