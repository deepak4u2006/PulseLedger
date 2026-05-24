// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PulseTransactions",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "PulseTransactions", targets: ["PulseTransactions"]),
    ],
    dependencies: [
        .package(path: "../PulseCore"),
        .package(path: "../PulseDesign"),
        .package(path: "../PulseNetworking"),
        .package(path: "../PulseNotify"),
        .package(path: "../PulseBridge"),
    ],
    targets: [
        .target(
            name: "PulseTransactions",
            dependencies: [
                "PulseCore",
                "PulseDesign",
                "PulseNetworking",
                "PulseNotify",
                "PulseBridge",
            ]
        ),
    ]
)
