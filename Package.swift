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
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(
            name: "Squirrel3",
            url: "https://github.com/heckj/Squirrel3.git", .upToNextMajor(from: "1.1.0")
        ),
        .package(
            name: "SceneKitDebugTools",
            url: "https://github.com/heckj/SceneKitDebugTools.git", .upToNextMajor(from: "0.1.0")
        ),
    ],
    targets: [
        .target(
            name: "Lindenmayer",
            dependencies: ["Squirrel3", "SceneKitDebugTools"]
        ),
        .target(
            name: "LindenmayerViews",
            dependencies: ["Lindenmayer", "SceneKitDebugTools"]
        ),
        .testTarget(
            name: "LindenmayerTests",
            dependencies: ["Lindenmayer", "Squirrel3", "SceneKitDebugTools"]
        ),
    ]
)
// Add the documentation compiler plugin if possible
#if swift(>=5.6)
    package.dependencies.append(
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    )
#endif
