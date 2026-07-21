// swift-tools-version: 6.3.3

import PackageDescription

let package = Package(
    name: "swift-coder-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Coder Primitives",
            targets: ["Coder Primitives"]
        ),
        .library(
            name: "Coder Parser Primitives",
            targets: ["Coder Parser Primitives"]
        ),
        .library(
            name: "Coder Primitives Test Support",
            targets: ["Coder Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-parser-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-serializer-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-either-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-product-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-pair-primitives.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Coder Primitives",
            dependencies: [
                .product(name: "Parser Primitives Core", package: "swift-parser-primitives"),
                .product(name: "Serializer Primitives Core", package: "swift-serializer-primitives"),
                .product(name: "Either Primitives", package: "swift-either-primitives"),
            ]
        ),

        // MARK: - Parser combinator emission rows (the coder-unification surface)

        .target(
            name: "Coder Parser Primitives",
            dependencies: [
                "Coder Primitives",
                .product(name: "Parser Primitives", package: "swift-parser-primitives"),
                .product(name: "Parser Pair Primitives", package: "swift-parser-primitives"),
                .product(name: "Serializer Primitives Core", package: "swift-serializer-primitives"),
                .product(name: "Either Primitives", package: "swift-either-primitives"),
                .product(name: "Product Primitives", package: "swift-product-primitives"),
                .product(name: "Pair Primitives", package: "swift-pair-primitives"),
            ]
        ),

        // MARK: - Tests

        .target(
            name: "Coder Primitives Test Support",
            dependencies: ["Coder Primitives"],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Coder Parser Primitives Tests",
            dependencies: ["Coder Parser Primitives"],
            path: "Tests/Coder Parser Primitives Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
