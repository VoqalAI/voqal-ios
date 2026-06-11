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
            url: "https://voqal-sdk-releases-eu.s3.eu-west-1.amazonaws.com/VoqalSDK-1.0.6.zip",
            checksum: "0c8a61b170f82ec820894406cccbbc1a7c826c09f9658d2b154c9826ba8222ec"
        ),
    ]
)
