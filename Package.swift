// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ByteCoder",
    products: [
        .library(
            name: "ByteCoder",
            targets: ["ByteCoder"]),
    ],
    dependencies: [
        .package(url: "https://github.com/idexus/BinaryFlags.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "ByteCoder",
            dependencies: ["BinaryFlags"]),
        .testTarget(
            name: "ByteCoderTests",
            dependencies: ["ByteCoder", "BinaryFlags"]),
    ]
)
