// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PulseNetworking",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "PulseNetworking", targets: ["PulseNetworking"]),
    ],
    dependencies: [
        .package(path: "../PulseDesign"),
    ],
    targets: [
        .target(
            name: "PulseNetworking",
            dependencies: ["PulseDesign"]
        ),
    ]
)
