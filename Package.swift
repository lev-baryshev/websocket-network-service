// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let coreToolkit: Target.Dependency = .product(name: "CoreToolkit", package: "CoreToolkit")

let package = Package(
    name: "WebsocketNetworkService",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "WebsocketNetworkService", targets: ["WebsocketNetworkService"])
    ],
    dependencies: [
        .package(name: "CoreToolkit", path: "../core-toolkit"),
        .package(url: "https://github.com/daltoniam/Starscream.git", exact: Version(4, 0, 4))
    ],
    targets: [
        .target(
            name: "WebsocketNetworkService",
            dependencies: [coreToolkit, "Starscream"],
            path: "Sources")
    ]
)
