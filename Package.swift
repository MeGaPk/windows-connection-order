// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "WindowsConnectionOrder",
    defaultLocalization: "en",
    products: [
        .executable(
            name: "WindowsConnectionOrder",
            targets: ["EntryPoint"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/moreSwift/swift-cross-ui",
            exact: "0.8.0"
        )
    ],
    targets: [
        .target(name: "Domain"),
        .target(name: "Utils"),
        .target(name: "Gateway", dependencies: ["Domain"]),
        .target(name: "GatewayImpl", dependencies: ["Domain", "Gateway"]),
        .target(name: "Repository", dependencies: ["Domain", "Localization"]),
        .target(
            name: "RepositoryImpl",
            dependencies: ["Domain", "Gateway", "Localization", "Repository", "Utils"]
        ),
        .target(name: "UseCase", dependencies: ["Domain", "Localization"]),
        .target(
            name: "UseCaseImpl",
            dependencies: ["Domain", "Localization", "Repository", "UseCase"]
        ),
        .target(
            name: "Localization",
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
                "Domain",
                "Localization",
                "UIUtils",
                "UseCase",
                .product(name: "SwiftCrossUI", package: "swift-cross-ui")
            ]
        ),
        .executableTarget(
            name: "EntryPoint",
            dependencies: [
                "GatewayImpl",
                "Localization",
                "Nodes",
                "RepositoryImpl",
                "UseCaseImpl",
                .product(name: "DefaultBackend", package: "swift-cross-ui"),
                .product(name: "SwiftCrossUI", package: "swift-cross-ui")
            ]
        )
    ]
)
