// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Lindenmayer",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
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
    ],
    targets: [
        .target(
            name: "Lindenmayer",
            dependencies: ["Squirrel3"]
        ),
        .target(
            name: "LindenmayerViews",
            dependencies: ["Lindenmayer"]
        ),
        .testTarget(
            name: "LindenmayerTests",
            dependencies: ["Lindenmayer", "Squirrel3"]
        ),
    ]
)
