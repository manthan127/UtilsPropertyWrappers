// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UtilsPropertyWrappers",
    platforms: [.macOS(.v11), .iOS(.v14), .tvOS(.v14), .watchOS(.v7)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "UtilsPropertyWrappers",
            targets: ["UtilsPropertyWrappers"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/nalexn/ViewInspector", exact: "0.10.0") // from: "0.10.0"
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "UtilsPropertyWrappers"
        ),
        .testTarget(
            name: "UtilsPropertyWrappersTests",
            dependencies: [
                "UtilsPropertyWrappers",
                .product(name: "ViewInspector", package: "ViewInspector")
            ]
        )
    ]
)
