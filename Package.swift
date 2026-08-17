// swift-tools-version: 6.3.3

import PackageDescription

let package = Package(
    name: "swift-coder-primitives",
    platforms: [
        .macOS("27"),
        .iOS("27"),
        .tvOS("27"),
        .watchOS("27"),
        .visionOS("27"),
    ],
    products: [
        .library(
            name: "Coder Primitive",
            targets: ["Coder Primitive"]
        ),
        .library(
            name: "Coder Witness Primitives",
            targets: ["Coder Witness Primitives"]
        ),
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
            name: "Coder Primitive",
            dependencies: [
                .product(name: "Parser Primitives Core", package: "swift-parser-primitives"),
                .product(name: "Serializer Primitives Core", package: "swift-serializer-primitives"),
            ]
        ),
        // The protocol-defining module must not contain a `Body == Never`
        // conformer. Keeping the closure-backed leaf in a sibling target
        // prevents its default `body.read` accessor from being serialized
        // into downstream leaf modules as a bodiless SIL function.
        .target(
            name: "Coder Witness Primitives",
            dependencies: [
                .target(name: "Coder Primitive"),
            ]
        ),
        // Compatibility umbrella: existing consumers keep importing
        // `Coder_Primitives`, while the defining and conforming declarations
        // remain separated at the module boundary.
        .target(
            name: "Coder Primitives",
            dependencies: [
                .target(name: "Coder Primitive"),
                .target(name: "Coder Witness Primitives"),
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
        .target(
            name: "Coder Module Boundary Control",
            dependencies: [.target(name: "Coder Primitives")],
            path: "Tests/Coder Module Boundary Control",
            swiftSettings: [
                // Binding two-module control for swift-coder-primitives#4:
                // this downstream leaf must survive full SIL verification.
                .unsafeFlags([
                    "-Xfrontend", "-sil-verify-all",
                    "-Xfrontend", "-whole-module-optimization",
                ]),
            ]
        ),
        .testTarget(
            name: "Coder Module Boundary Tests",
            dependencies: [
                .target(name: "Coder Module Boundary Control"),
                .target(name: "Coder Primitives"),
            ],
            path: "Tests/Coder Module Boundary Tests"
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
