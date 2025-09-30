// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwineCraft_XP",
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.86.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.15.0"),
        .package(url: "https://github.com/apple/swift-atomics.git", from: "1.3.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "SwakNet",
        dependencies: [
            .product(name: "NIO", package: "swift-nio")
        ]),
        .executableTarget(
            name: "SwineCraft_XP", dependencies: [
                .target(name: "SwakNet"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "Crypto", package: "swift-crypto")
            ]),
        .testTarget(
            name: "SwineCraft_XPTests"
        ),
    ]
)
