// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MonkeyLang",
  platforms: [
    .macOS(.v14),
  ],
  products: [
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
    .package(url: "https://github.com/Quick/Nimble.git", from: "13.2.1"),
  ],
  targets: [
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
      dependencies: [
        "MonkeyLang",
        .product(name: "Nimble", package: "nimble"),
      ]
    )
  ]
)
