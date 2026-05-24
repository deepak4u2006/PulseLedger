// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PulseAuth",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "PulseAuth", targets: ["PulseAuth"]),
    ],
    dependencies: [
        .package(path: "../PulseCore"),
        .package(path: "../PulseDesign"),
        .package(path: "../PulseSecurity"),
        .package(url: "https://github.com/airbnb/lottie-ios", from: "4.5.0"),
    ],
    targets: [
        .target(
            name: "PulseAuth",
            dependencies: [
                "PulseCore",
                "PulseDesign",
                "PulseSecurity",
                .product(name: "Lottie", package: "lottie-ios"),
            ],
            resources: [.process("Resources")]
        ),
    ]
)
