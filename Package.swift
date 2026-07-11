// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "WindowsConnectionOrder",
    products: [
        .executable(
            name: "WindowsConnectionOrder",
            targets: ["WindowsConnectionOrder"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/moreSwift/swift-cross-ui",
            exact: "0.8.0"
        )
    ],
    targets: [
        .executableTarget(
            name: "WindowsConnectionOrder",
            dependencies: [
                .product(name: "SwiftCrossUI", package: "swift-cross-ui"),
                .product(name: "DefaultBackend", package: "swift-cross-ui")
            ],
            path: "Sources/WindowsNetworkManager"
        )
    ]
)
