// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwineCraft_XP",
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.86.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.15.0"),
        .package(url: "https://github.com/apple/swift-nio-extras.git", from: "1.29.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.13.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: Version(6, 0, 0))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .systemLibrary(
            name: "SwiftZlib",
            pkgConfig: "zlib"
        ),
        .systemLibrary(
            name: "SwiftSnappy",
            pkgConfig: "snappy"
        ),
        .target(
            name: "SwiftNBT",
            dependencies: [
                .product(name: "NIO", package: "swift-nio")
            ],
        ),
        .target(name: "SwakNet",
            dependencies: [
                .product(name: "NIO", package: "swift-nio")
        ]),
        .executableTarget(
            name: "SwineCraft_XP", dependencies: [
                .target(name: "SwakNet"),
                .target(name: "SwiftZlib"),
                .target(name: "SwiftSnappy"),
                .target(name: "SwiftNBT"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "NIOExtras", package: "swift-nio-extras"),
            ]),
        .testTarget(
            name: "SwineCraft_XPTests",
            dependencies: [.target(name: "SwineCraft_XP")]
        ),
    ]
)
