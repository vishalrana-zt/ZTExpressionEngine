// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ZTExpressionEngine",
    platforms: [
        .iOS(.v13),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "ZTExpressionEngine",
            targets: ["ZTExpressionEngine"]
        )
    ],
    targets: [
        .target(
            name: "ZTExpressionEngine",
            path: "Sources/ZTExpressionEngine"
        ),
        .testTarget(
            name: "ZTExpressionEngineTests",
            dependencies: ["ZTExpressionEngine"],
            path: "Tests/ZTExpressionEngineTests"
        )
    ]
)
