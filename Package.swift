// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MonkeyLang",
  platforms: [
    .macOS(.v14),
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "MonkeyLang",
      targets: ["MonkeyLang"]
    ),
    .executable(
      name: "MonkeyCLI",
      targets: ["MonkeyCLI"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-case-paths.git", from: "1.3.0"),
    .package(url: "https://github.com/danielsincere/IdentifiedEnumCases.git", from: "1.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "MonkeyLang",
      dependencies: [
        .product(name: "CasePaths", package: "swift-case-paths"),
        .product(name: "IdentifiedEnumCases", package: "identifiedenumcases"),
      ]
    ),
    .executableTarget(
      name: "MonkeyCLI",
      dependencies: ["MonkeyLang"]
    ),
    .testTarget(
      name: "MonkeyLangTests",
      dependencies: ["MonkeyLang"]
    )
  ]
)
