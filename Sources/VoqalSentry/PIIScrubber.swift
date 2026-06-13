//
//  PIIScrubber.swift
//  VoqalSentry
//
//  Defence-in-depth redaction. The SDK never logs raw tokens/PII by design, but
//  this strips anything that looks like a bearer token, email, phone number, or a
//  URL query string from outgoing Sentry payloads before they leave the device.
//

import Foundation
import Sentry

enum PIIScrubber {
    private static let patterns: [NSRegularExpression] = {
        let sources = [
            #"[A-Za-z0-9_\-]{20,}\.[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}"#, // JWT-ish
            #"[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}"#,               // email
            #"\+?\d[\d \-]{7,}\d"#,                                              // phone
            #"\?[^\s]+"#,                                                         // URL query
        ]
        return sources.compactMap { try? NSRegularExpression(pattern: $0) }
    }()

    private static func redact(_ text: String) -> String {
        var result = text
        for regex in patterns {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, range: range, withTemplate: "[redacted]")
        }
        return result
    }

    static func scrub(_ event: Event) {
        if let message = event.message?.formatted {
            event.message = SentryMessage(formatted: redact(message))
        }
        event.extra = event.extra?.mapValues { value in
            (value as? String).map { redact($0) as Any } ?? value
        }
    }

    static func scrub(_ crumb: Breadcrumb) {
        if let message = crumb.message { crumb.message = redact(message) }
        crumb.data = crumb.data?.mapValues { value in
            (value as? String).map { redact($0) as Any } ?? value
        }
    }
}
