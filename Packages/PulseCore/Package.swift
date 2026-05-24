// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PulseCore",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "PulseCore", targets: ["PulseCore"]),
    ],
    targets: [
        .target(
            name: "PulseCore",
            resources: [.process("Resources")]
        ),
    ]
)
