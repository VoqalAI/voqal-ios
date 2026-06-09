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
            url: "https://voqal-sdk-releases-eu.s3.eu-west-1.amazonaws.com/VoqalSDK-1.0.0.zip",
            checksum: "24ab5547e3a4198819db6f6ad446b9f969d2fdf88565d77c884214ff37f27aab"
        ),
    ]
)
