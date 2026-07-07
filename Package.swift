// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "VoqalSDK",
    platforms: [.iOS(.v16)],
    products: [
        // One product. Adding it links the SDK + the Sentry bridge, and the SDK
        // auto-starts observability in setup() — no extra code. See OBSERVABILITY.md.
        .library(name: "VoqalSDK", targets: ["VoqalSDKBinary", "VoqalSentry"]),
    ],
    dependencies: [
        .package(url: "https://github.com/getsentry/sentry-cocoa", from: "8.0.0"),
    ],
    targets: [
        .binaryTarget(
            name: "VoqalSDKBinary",
            url: "https://voqal-sdk-releases-eu.s3.eu-west-1.amazonaws.com/VoqalSDK-1.3.3.zip",
            checksum: "a172b871283a7a8d78ae93c4a29e909b6b3c5e2e78f68f785e2528fcd6e2a32c"
        ),
        .target(
            name: "VoqalSentry",
            dependencies: [
                "VoqalSDKBinary",
                .product(name: "Sentry", package: "sentry-cocoa"),
            ]
        ),
    ]
)
