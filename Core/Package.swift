// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "Core",
    products: [
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "UseCase", targets: ["UseCase"]),
        .library(name: "AppComposition", targets: ["AppComposition"])
    ],
    targets: [
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
            dependencies: [
                "Gateway",
                "GatewayImpl",
                "RepositoryImpl",
                "UseCase",
                "UseCaseImpl",
                .target(
                    name: "WindowsNetworkGatewayImpl",
                    condition: .when(platforms: [.windows])
                )
            ]
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: ["Domain"]
        )
    ]
)
