// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AirpayKitPlugin",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "AirpayKitPlugin",
            targets: ["MyCustomPluginPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "MyCustomPluginPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/MyCustomPluginPlugin"),
        .testTarget(
            name: "MyCustomPluginPluginTests",
            dependencies: ["MyCustomPluginPlugin"],
            path: "ios/Tests/MyCustomPluginPluginTests")
    ]
)