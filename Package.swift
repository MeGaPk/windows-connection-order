// swift-tools-version: 6.3

import PackageDescription

var packageDependencies: [Package.Dependency] = [
    .package(
        url: "https://github.com/apple/swift-argument-parser",
        exact: "1.8.2"
    )
]

#if os(Windows)
packageDependencies.append(
    .package(
        url: "https://github.com/moreSwift/swift-cross-ui",
        exact: "0.8.0"
    )
)
#endif

var products: [Product] = [
    .executable(
        name: "WindowsConnectionOrderCLI",
        targets: ["CommandLine"]
    )
]

var appCompositionDependencies = [
    "Gateway",
    "GatewayImpl",
    "RepositoryImpl",
    "UseCase",
    "UseCaseImpl"
]

#if os(Windows)
appCompositionDependencies.append("WindowsNetworkGatewayImpl")
products.append(
    .executable(
        name: "WindowsConnectionOrder",
        targets: ["EntryPoint"]
    )
)
#endif

var targets: [Target] = [
    .target(name: "Domain"),
    .target(name: "Utils"),
    .target(name: "Gateway", dependencies: ["Domain"]),
    .target(
        name: "GatewayImpl",
        dependencies: ["Domain", "Gateway"]
    ),
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
        dependencies: appCompositionDependencies
    ),
    .target(
        name: "Localization",
        dependencies: ["Domain"],
        resources: [.process("Resources")]
    ),
    .executableTarget(
        name: "CommandLine",
        dependencies: [
            "AppComposition",
            "Domain",
            .product(name: "ArgumentParser", package: "swift-argument-parser")
        ]
    )
]

#if os(Windows)
targets.append(
    contentsOf: [
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
                "AppComposition",
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
#endif

targets.append(
    .testTarget(
        name: "WindowsConnectionOrderTests",
        dependencies: []
    )
)

let package = Package(
    name: "WindowsConnectionOrder",
    defaultLocalization: "en",
    products: products,
    dependencies: packageDependencies,
    targets: targets
)
