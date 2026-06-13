# Voqal SDK — Observability (Sentry) Setup

Full tracing for the Voqal SDK: every error, the flow that led to it, **who** the
user was, **which device**, **which tenant**, and **which environment** — surfaced
in Sentry with performance traces for each turn.

The core SDK has **no Sentry dependency**. Sentry lives in a separate SPM product,
`VoqalSentry`. Add it and call one line; everything else flows automatically.

---

## 1. Create the Sentry project (one time)

1. In Sentry → **Projects → Create Project** → platform **Apple / iOS** → name it
   `voqal-ios` (or per-tenant if you prefer separate dashboards).
2. Copy the **DSN** (Settings → Client Keys (DSN)). It looks like
   `https://<hash>@o<org>.ingest.sentry.io/<project>`.
3. A DSN is **safe to embed in a mobile client** — it can only *send* events, not
   read them. Two options:
   - **Voqal-managed (recommended):** paste the DSN into
     `VoqalObservability.defaultDSN` in the SDK source and re-cut the SDK. Every
     integrator then reports to your Sentry with zero setup on their side.
   - **Integrator-managed:** leave the default empty and have each integrator pass
     their own DSN (step 3 below).

---

## 2. Add the package

Same URL as the SDK; add the **`VoqalSentry`** library product alongside `VoqalSDK`:

```
https://github.com/VoqalAI/voqal-ios  →  add both products:
  • VoqalSDK
  • VoqalSentry
```

`VoqalSentry` transitively pulls in `sentry-cocoa`; no other setup.

---

## 3. Turn it on (one line, at launch)

```swift
import VoqalSDK
import VoqalSentry

// AppDelegate / App init — BEFORE VoqalSDKManager.setup:
VoqalSentry.enable()                                  // uses the baked Voqal DSN

// …or point at your own Sentry project / tune sampling:
VoqalSentry.enable(options: .init(
    dsn: "https://…ingest.sentry.io/…",
    tracesSampleRate: 1.0,    // 1.0 = trace every flow; lower in high volume
    scrubPII: true            // redact token/email/phone/URL-query (default on)
))

VoqalSDKManager.shared.setup(configuration: config)
```

To disable entirely: `VoqalSentry.enable(options: .init(enabled: false))` — or just
don't add the product.

---

## 4. What you get in Sentry

**Issues (errors)** — every error the SDK reports is captured with:
- **User** = the end user's `user_id` (from your delegate's `getMetaData()`).
- **Tags** you can filter/group by: `environment` (production/staging),
  `tenant` (a non-reversible fingerprint of the `pk_…` key — never the key
  itself), `session_id`, `sdk_version`, `device_model`, `os_version`, `locale`.
- **Breadcrumbs** = the last ~40 steps before it broke (session bootstrap → turn →
  first token → widgets → the failing call), so you see *what they were doing*.
- Device, OS, app version — captured automatically by sentry-cocoa.

**Performance (traces)** — one transaction per flow, with child spans + timings:

| Transaction | Spans | Tells you |
|---|---|---|
| `session.bootstrap` | — | how long create-session + warm took, ok/failed |
| `turn` | `turn.first_token` | time-to-first-token vs total; `events` count |
| `voice.turn` | (turn spans) | clip size, end-to-end voice latency |
| `turn.execute` | — | confirm→action latency, `done` type, ok/failed |

A failed span is marked `internal_error`, so a slow or broken turn shows exactly
**which step** stalled and **where** it failed.

---

## 5. Dashboard tips

- **Group by `tenant`** to see per-merchant health.
- **Filter `environment:production`** to exclude staging noise.
- **Discover query** on `transaction:turn` + p95 `turn.first_token` to watch STT/LLM
  latency over time.
- Set an **alert** on the `turn`/`voice.turn` failure rate to catch engine/MCP
  outages before users report them.

---

## 6. Privacy

- Nothing leaves the device unless `VoqalSentry.enable()` is called.
- The SDK never logs raw tokens or PII; `PIIScrubber` is a second line of defence
  that redacts anything token/email/phone/URL-query-shaped before send.
- The tenant tag is a salted fingerprint of the publishable key, not the key.
