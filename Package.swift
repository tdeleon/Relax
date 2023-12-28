// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Relax",
    platforms: [
        .iOS(.v14),
        .tvOS(.v14),
        .watchOS(.v7),
        .macOS(.v12),
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
        // Depend on the Swift 5.9 release of SwiftSyntax
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Relax",
            dependencies: ["RelaxMacros"]),
        .macro(
            name: "RelaxMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "URLMock",
            dependencies: ["Relax"]
        ),
        .testTarget(
            name: "RelaxTests",
            dependencies: ["Relax", "URLMock", .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")]
        ),
    ]
)
