// swift-tools-version:5.5

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
        .package(
            name: "SceneKitDebugTools",
            url: "https://github.com/heckj/SceneKitDebugTools.git", .upToNextMajor(from: "0.1.0")
        ),
    ],
    targets: [
        .target(
            name: "Lindenmayer",
            dependencies: ["SceneKitDebugTools"]
        ),
        .target(
            name: "LindenmayerViews",
            dependencies: ["Lindenmayer", "SceneKitDebugTools"]
        ),
        .testTarget(
            name: "LindenmayerTests",
            dependencies: ["Lindenmayer", "SceneKitDebugTools"]
        ),
    ]
)
// Add the documentation compiler plugin if possible
#if swift(>=5.6)
    package.dependencies.append(
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    )
#endif
