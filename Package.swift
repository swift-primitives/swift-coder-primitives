// swift-tools-version: 6.2

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
    ],
    dependencies: [
        .package(path: "../swift-serialization-primitives"),
        .package(path: "../swift-binary-primitives"),
        .package(path: "../swift-ascii-primitives"),
        .package(path: "../swift-error-primitives"),
    ],
    targets: [
        .target(
            name: "Coder Primitives",
            dependencies: [
                .product(name: "Serialization Primitives", package: "swift-serialization-primitives"),
                .product(name: "Binary Primitives", package: "swift-binary-primitives"),
                .product(name: "ASCII Primitives", package: "swift-ascii-primitives"),
                .product(name: "Error Primitives", package: "swift-error-primitives"),
            ]
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
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableExperimentalFeature("SuppressedAssociatedTypesWithDefaults"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
