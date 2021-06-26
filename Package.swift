// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "SwiftMixin",
  products: [
    .library(name: "SwiftMixin", targets: ["SwiftMixin"])
  ],
  dependencies: [
    .package(
      name:"Capstone",
      url: "https://github.com/zydeco/capstone-swift",
      .branch("v4"))
  ],
  targets: [
    .target(
      name: "SwiftMixin",
      dependencies: ["SwiftMixinC", "Capstone"]),
    .target(
      name: "SwiftMixinC",
      dependencies: []),
    .testTarget(
      name: "SwiftMixinTests",
      dependencies: ["SwiftMixin"]),
  ]
)
