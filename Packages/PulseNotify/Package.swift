// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PulseNotify",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "PulseNotify", targets: ["PulseNotify"]),
    ],
    targets: [
        .target(name: "PulseNotify"),
    ]
)
