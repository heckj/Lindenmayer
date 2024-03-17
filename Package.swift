// swift-tools-version:5.8

import PackageDescription

let package = Package(
    name: "Lindenmayer",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
    ],
    products: [
        .library(
            name: "Lindenmayer",
            targets: ["Lindenmayer"]
        ),
        .library(name: "LindenmayerViews", targets: ["LindenmayerViews"]),
    ],
    dependencies: [
        .package(url: "https://github.com/heckj/SceneKitDebugTools.git", from: "0.1.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Lindenmayer",
            dependencies: ["SceneKitDebugTools"],
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),
        .target(
            name: "LindenmayerViews",
            dependencies: ["Lindenmayer", "SceneKitDebugTools"],
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),
        .testTarget(
            name: "LindenmayerTests",
            dependencies: ["Lindenmayer", "SceneKitDebugTools"]
        ),
    ]
)
