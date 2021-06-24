// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MixinTest",
  products: [
    .executable(name: "MixinTest", targets: ["MixinTest"])
  ],
  dependencies: [
    .package(
      name:"Capstone",
      url: "https://github.com/zydeco/capstone-swift",
      .branch("v4"))
  ],
  targets: [
    .target(
      name: "MixinTest",
      dependencies: ["MixinTestC", "Capstone"]),
    .target(
      name: "MixinTestC",
      dependencies: []),
    .testTarget(
      name: "MixinTestTests",
      dependencies: ["MixinTest"]),
  ]
)
