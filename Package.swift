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
        .package(
            url: "https://github.com/moreSwift/swift-cross-ui",
            exact: "0.8.0"
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            exact: "1.8.2"
        )
    ],
    targets: [
        .target(name: "Domain"),
        .target(name: "Utils"),
        .target(name: "Gateway", dependencies: ["Domain"]),
        .target(name: "GatewayImpl", dependencies: ["Domain", "Gateway"]),
        .target(
            name: "WindowsNetworkGatewayImpl",
            dependencies: ["Domain", "Gateway"]
        ),
        .target(name: "Repository", dependencies: ["Domain"]),
        .target(
            name: "RepositoryImpl",
            dependencies: ["Domain", "Gateway", "Repository", "Utils"]
        ),
        .target(name: "UseCase", dependencies: ["Domain"]),
        .target(
            name: "UseCaseImpl",
            dependencies: ["Domain", "Repository", "UseCase"]
        ),
        .target(
            name: "AppComposition",
            dependencies: [
                "Gateway",
                "GatewayImpl",
                "RepositoryImpl",
                "UseCase",
                "UseCaseImpl",
                "WindowsNetworkGatewayImpl"
            ]
        ),
        .target(
            name: "Localization",
            dependencies: ["Domain"],
            resources: [.process("Resources")]
        ),
        .target(
            name: "UIUtils",
            dependencies: [
                .product(
                    name: "SwiftCrossUI",
                    package: "swift-cross-ui",
                    condition: .when(platforms: [.windows])
                )
            ]
        ),
        .target(
            name: "Nodes",
            dependencies: [
                "Domain",
                "Localization",
                "UIUtils",
                "UseCase",
                .product(
                    name: "SwiftCrossUI",
                    package: "swift-cross-ui",
                    condition: .when(platforms: [.windows])
                )
            ]
        ),
        .executableTarget(
            name: "EntryPoint",
            dependencies: [
                "AppComposition",
                "Localization",
                "Nodes",
                "RepositoryImpl",
                "UseCaseImpl",
                .product(
                    name: "DefaultBackend",
                    package: "swift-cross-ui",
                    condition: .when(platforms: [.windows])
                ),
                .product(
                    name: "SwiftCrossUI",
                    package: "swift-cross-ui",
                    condition: .when(platforms: [.windows])
                )
            ]
        ),
        .executableTarget(
            name: "CommandLine",
            dependencies: [
                "AppComposition",
                "Domain",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "WindowsConnectionOrderTests",
            dependencies: []
        )
    ]
)
