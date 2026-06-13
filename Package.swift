// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "VoqalSDK",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "VoqalSDK", targets: ["VoqalSDK"]),
        // Optional observability: forwards SDK errors/traces/breadcrumbs to Sentry.
        // Add this product + call VoqalSentry.enable() to turn it on. See OBSERVABILITY.md.
        .library(name: "VoqalSentry", targets: ["VoqalSentry"]),
    ],
    dependencies: [
        .package(url: "https://github.com/getsentry/sentry-cocoa", from: "8.0.0"),
    ],
    targets: [
        .binaryTarget(
            name: "VoqalSDK",
            url: "https://voqal-sdk-releases-eu.s3.eu-west-1.amazonaws.com/VoqalSDK-1.1.0.zip",
            checksum: "6d6e94de533a5334b03ed405b9289e6b0e5a36653126836e8eb6bb78f45da63d"
        ),
        .target(
            name: "VoqalSentry",
            dependencies: [
                "VoqalSDK",
                .product(name: "Sentry", package: "sentry-cocoa"),
            ]
        ),
    ]
)
