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
            url: "https://voqal-sdk-releases-eu.s3.eu-west-1.amazonaws.com/VoqalSDK-1.0.4.zip",
            checksum: "59de0d43aadf5689f31f97f199bc47cd3e8f90e5d83ffe3cf10b36486f913f20"
        ),
    ]
)
