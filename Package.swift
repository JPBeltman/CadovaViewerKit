// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CadovaViewerKit",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "CadovaViewerKit",
            targets: ["CadovaViewerKit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/tomasf/Cadova.git", .upToNextMinor(from: "0.6.1")),

    ],
    targets: [
        .target(
            name: "CadovaViewerKit",
            dependencies: [
                .product(name: "Cadova", package: "Cadova"),
            ],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
        .testTarget(
            name: "CadovaViewerKitTests",
            dependencies: ["CadovaViewerKit"],
            swiftSettings: [.interoperabilityMode(.Cxx)]
        ),
    ],
    swiftLanguageModes: [.v6]
)
