// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "WindowsConnectionOrder",
    defaultLocalization: "en",
    products: [
        .executable(
            name: "WindowsConnectionOrder",
            targets: ["EntryPoint"]
        ),
        .executable(
            name: "WindowsConnectionOrderCLI",
            targets: ["CommandLine"]
        )
    ],
    dependencies: [
        .package(path: "Core"),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            exact: "1.8.2"
        ),
        .package(
            url: "https://github.com/moreSwift/swift-cross-ui",
            exact: "0.8.0"
        )
    ],
    targets: [
        .target(
            name: "Localization",
            dependencies: [
                .product(name: "Domain", package: "Core")
            ],
            resources: [.process("Resources")]
        ),
        .target(
            name: "UIUtils",
            dependencies: [
                .product(name: "SwiftCrossUI", package: "swift-cross-ui")
            ]
        ),
        .target(
            name: "Nodes",
            dependencies: [
                "Localization",
                "UIUtils",
                .product(name: "Domain", package: "Core"),
                .product(name: "UseCase", package: "Core"),
                .product(name: "SwiftCrossUI", package: "swift-cross-ui")
            ]
        ),
        .executableTarget(
            name: "CommandLine",
            dependencies: [
                .product(name: "AppComposition", package: "Core"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .executableTarget(
            name: "EntryPoint",
            dependencies: [
                "Localization",
                "Nodes",
                .product(name: "AppComposition", package: "Core"),
                .product(name: "Domain", package: "Core"),
                .product(name: "DefaultBackend", package: "swift-cross-ui"),
                .product(name: "SwiftCrossUI", package: "swift-cross-ui")
            ]
        )
    ]
)
