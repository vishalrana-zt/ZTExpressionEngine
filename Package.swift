// swift-tools-version: 5.9

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
	    resources: [
                .process("Sources/ZTExpressionEngine")
            ]
        ),
        .testTarget(
            name: "ZTExpressionEngineTests",
            dependencies: ["ZTExpressionEngine"],
	    resources: [
                .process("Tests/ZTExpressionEngineTests")
            ]
        )
    ]
)
