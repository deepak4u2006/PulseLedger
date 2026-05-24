// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PulseDesign",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "PulseDesign", targets: ["PulseDesign"]),
    ],
    dependencies: [
        .package(path: "../PulseCore"),
    ],
    targets: [
        .target(
            name: "PulseDesign",
            dependencies: ["PulseCore"]
        ),
    ]
)
