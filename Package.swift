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
            url: "https://voqal-sdk-releases-eu.s3.eu-west-1.amazonaws.com/VoqalSDK-1.3.5.zip",
            checksum: "25aeb1836454f264182b0b37c615ee3ed46249854b6a9c8a4fd9bd23de91ddef"
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
