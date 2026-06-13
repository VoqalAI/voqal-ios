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
            url: "https://voqal-sdk-releases-eu.s3.eu-west-1.amazonaws.com/VoqalSDK-1.2.1.zip",
            checksum: "b14e673c8502bc2d81a56962597188fc3ba994817954894a69a2eea1e7bff516"
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
