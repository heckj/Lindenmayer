// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Lindenmayer",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "Lindenmayer",
            targets: ["Lindenmayer"]
        ),
        .library(name: "LindenmayerViews", targets: ["LindenmayerViews"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Lindenmayer",
            dependencies: []
        ),
        .target(
            name: "LindenmayerViews",
            dependencies: ["Lindenmayer"]
        ),
        .testTarget(
            name: "LindenmayerTests",
            dependencies: ["Lindenmayer"]
        ),
    ]
)
