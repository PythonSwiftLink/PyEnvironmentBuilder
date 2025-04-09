// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PyEnvironmentBuilder",
    platforms: [.macOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PyEnvironmentBuilder",
            targets: ["PyEnvironmentBuilder"]),
        .executable(name: "RunBuild", targets: ["RunBuild"])
    ],
    dependencies: [
        .package(url: "https://github.com/kylef/PathKit", .upToNextMajor(from: "1.0.1")),
        .package(url: "https://github.com/apple/swift-algorithms.git", .upToNextMajor(from: "1.2.0")),
        .package(url: "https://github.com/YusukeHosonuma/SwiftPrettyPrint", .upToNextMajor(from: "1.4.0")),
        .package(url: "https://github.com/swiftlang/swift-syntax", .upToNextMajor(from: "509.0.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Recipe",
            dependencies: [
                "PyEnvironmentBuilder",
                .product(name: "PathKit", package: "PathKit"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "SwiftPrettyPrint", package: "SwiftPrettyPrint")
            ],
            resources: [
                .copy("tools")
            ]
        ),
        
        .target(
            name: "Recipes",
            dependencies: [
                "PyEnvironmentBuilder",
                "Recipe",
                .product(name: "PathKit", package: "PathKit"),
                .product(name: "SwiftPrettyPrint", package: "SwiftPrettyPrint")
            ],
            resources: [
                .copy("patches"),
            ]
        ),
        
        .target(
            name: "PyEnvironmentBuilder",
            dependencies: [
                .product(name: "PathKit", package: "PathKit")
            ]
        ),
        .target(
            name: "SwiftPackageExporter",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                "Recipe",
                "Recipes",
                "PyEnvironmentBuilder"
            ]
        ),
        
        .executableTarget(
            name: "RunBuild",
            dependencies: [
                "PyEnvironmentBuilder",
                "Recipes",
                .product(name: "Algorithms", package: "swift-algorithms")
            ]
        ),
        .testTarget(
            name: "PyEnvironmentBuilderTests",
            dependencies: ["PyEnvironmentBuilder"]
        ),
    ]
)
