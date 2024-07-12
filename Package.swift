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
        .package(url: "https://github.com/Infomaniak/ios-core", .upToNextMajor(from: "11.0.0")),
        .package(url: "https://github.com/Infomaniak/ios-version-checker", .upToNextMajor(from: "6.0.0")),
    ],
    targets: [
        .target(
            name: "InfomaniakBugTracker",
            dependencies: [
                .product(name: "InfomaniakCore", package: "ios-core"),
                .product(name: "VersionChecker", package: "ios-version-checker"),
            ]
        ),
        .testTarget(
            name: "InfomaniakBugTrackerTests",
            dependencies: ["InfomaniakBugTracker"]
        ),
    ]
)
