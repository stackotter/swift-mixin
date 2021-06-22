// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MixinTest",
  dependencies: [
      
  ],
  targets: [
    .target(
      name: "MixinTest",
      dependencies: ["MixinTestC"]),
    .target(
      name: "MixinTestC",
      dependencies: []),
    .testTarget(
      name: "MixinTestTests",
      dependencies: ["MixinTest"]),
  ]
)
