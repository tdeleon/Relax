// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport


var targets: [Target] = [
    .target(
        name: "URLMock",
        dependencies: ["Relax"]
    ),
    .testTarget(
        name: "RelaxTests",
        dependencies: ["Relax", "URLMock"]
    ),
]

var dependencies = [Package.Dependency]()

// Macros do not currently compile on windows when building tests: https://github.com/apple/swift-package-manager/issues/7174
#if canImport(XCTest) && os(Windows)
targets.append(.target(name: "Relax"))
#else
targets.append(
    contentsOf: [
        .target(name: "Relax", dependencies: ["RelaxMacros"]),
        .macro(
            name: "RelaxMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .testTarget(
            name: "RelaxMacrosTests",
            dependencies: ["RelaxMacros", .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")]
        )
    ]
)
dependencies = [
    // Depend on the Swift 5.9 release of SwiftSyntax
    .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
]
#endif

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
    dependencies: dependencies,
    targets: targets
)
