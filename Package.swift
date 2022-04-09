// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Finance",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Finance",
            targets: ["Finance"]    
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/ABTSoftware/CCTALib", .upToNextMajor(from: "0.7.3")),
        .package(url: "https://github.com/ABTSoftware/SciChart-SP", .upToNextMajor(from: "4.4.0")),
    ],
    targets: [
        .target(
            name: "Finance",
            dependencies: [
                .product(name: "SwiftCCTALib", package: "CCTALib"),
                .product(name: "SciChart", package: "SciChart-SP")
            ],
            path: "Finance",
            exclude: [
                "Info.plist"
            ],
            resources: [
                .copy("Resources/NEUROPOL.ttf"),
                .copy("Resources/SciChart_Dark_Theme.plist")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
