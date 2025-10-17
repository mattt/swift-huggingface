// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-huggingface",
    platforms: [
        .macOS(.v13),
        .macCatalyst(.v13),
        .iOS(.v16),
        .watchOS(.v9),
        .tvOS(.v16),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "HuggingFace",
            targets: ["HuggingFace"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/mattt/EventSource.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Hub",
            path: "Sources/Hub"
        ),
        .target(
            name: "InferenceProviders",
            dependencies: [
                .product(name: "EventSource", package: "EventSource")
            ],
            path: "Sources/InferenceProviders"
        ),
        .target(
            name: "HuggingFace",
            dependencies: [
                .target(name: "Hub"),
                .target(name: "InferenceProviders"),
            ],
            path: "Sources/HuggingFace"
        ),
        .testTarget(
            name: "HuggingFaceTests",
            dependencies: ["HuggingFace", "Hub"]
        ),
    ]
)
