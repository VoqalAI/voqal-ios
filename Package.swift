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
            url: "https://voqal-sdk-releases-eu.s3.eu-west-1.amazonaws.com/VoqalSDK-1.4.0.zip",
            checksum: "c95263cfa5fa089774c8474e3f6bcab8403badd753ebc718f6a19c2ea4a25762"
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
