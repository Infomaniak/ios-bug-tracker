// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InfomaniakBugTracker",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "InfomaniakBugTracker",
            targets: ["InfomaniakBugTracker"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Infomaniak/ios-core", .upToNextMajor(from: "7.0.0")),
    ],
    targets: [
        .target(
            name: "InfomaniakBugTracker",
            dependencies: [
                .product(name: "InfomaniakCore", package: "ios-core"),
            ]
        ),
        .testTarget(
            name: "InfomaniakBugTrackerTests",
            dependencies: ["InfomaniakBugTracker"]
        ),
    ]
)
