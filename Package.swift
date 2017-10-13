// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "VaporFirestore",
    products: [
        .library(
            name: "VaporFirestore",
            targets: ["VaporFirestore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", 
                 from: "2.0.0")
    ],
    targets: [
        .target(
            name: "VaporFirestore",
            dependencies: []),
        .testTarget(
            name: "VaporFirestoreTests",
            dependencies: ["VaporFirestore"]),
    ]
)
