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
    ],
    targets: [
        .target(
            name: "ByteCoder",
            dependencies: []),
        .testTarget(
            name: "ByteCoderTests",
            dependencies: ["ByteCoder"]),
    ]
)
