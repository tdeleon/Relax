// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Relax",
    platforms: [
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .macOS(.v14),
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Relax",
            targets: ["Relax"]),
        .library(
            name: "URLMock",
            targets: ["URLMock"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Relax",
            dependencies: []
        ),
        .target(
            name: "URLMock",
            dependencies: ["Relax"]
        ),
        .testTarget(
            name: "RelaxTests",
            dependencies: ["Relax", "URLMock"]
        ),
    ],
    swiftLanguageModes: [.v5, .v6]
)
