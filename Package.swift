// swift-tools-version: 6.3

import PackageDescription
import Foundation

let lightweightTests = ProcessInfo.processInfo.environment[
    "WINDOWS_CONNECTION_ORDER_LIGHTWEIGHT_TESTS"
] == "1"

var packageDependencies: [Package.Dependency] = []
var products: [Product] = []
var targets: [Target] = [
    .target(name: "Domain"),
    .testTarget(
        name: "WindowsConnectionOrderTests",
        dependencies: ["Domain"]
    )
]

#if os(Windows)
if !lightweightTests {
packageDependencies = [
    .package(
        url: "https://github.com/apple/swift-argument-parser",
        exact: "1.8.2"
    ),
    .package(
        url: "https://github.com/moreSwift/swift-cross-ui",
        exact: "0.8.0"
    )
]

products = [
    .executable(
        name: "WindowsConnectionOrder",
        targets: ["EntryPoint"]
    ),
    .executable(
        name: "WindowsConnectionOrderCLI",
        targets: ["CommandLine"]
    )
]

targets.append(
    contentsOf: [
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
        .executableTarget(
            name: "CommandLine",
            dependencies: [
                "AppComposition",
                "Domain",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
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
}
#endif

let package = Package(
    name: "WindowsConnectionOrder",
    defaultLocalization: "en",
    products: products,
    dependencies: packageDependencies,
    targets: targets
)
