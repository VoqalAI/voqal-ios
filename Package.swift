// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "VoqalSDK",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "VoqalSDK", targets: ["VoqalSDK"]),
    ],
    targets: [
        .binaryTarget(
            name: "VoqalSDK",
            url: "https://voqal-sdk-releases-eu.s3.eu-west-1.amazonaws.com/VoqalSDK-1.0.10.zip",
            checksum: "3236814c80a8c29452ef096b354162fdec46580cf2726cb3f70b3c403ce53cf8"
        ),
    ]
)
