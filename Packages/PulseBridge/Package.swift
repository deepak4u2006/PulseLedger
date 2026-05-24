// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PulseBridge",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "PulseBridge", targets: ["PulseBridge"]),
    ],
    dependencies: [
        .package(path: "../PulseCore"),
        .package(path: "../PulseDesign"),
    ],
    targets: [
        .target(
            name: "PulseBridge",
            dependencies: ["PulseCore", "PulseDesign"]
        ),
    ]
)
