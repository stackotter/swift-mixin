# SwiftMixin

> Disclaimer: This package is very young and due to its nature, a small change to the swift compiler could brick this package. I will try my best to fix issues as fast as I can but this probably shouldn't be used in a production app.

## Quick Overview

SwiftMixin has all of the functionality required to overwrite functions and methods at runtime. It also allows you to create backups of functions before you overwrite them so that you can still use the original function. This package was made for a Swift plugin system ([Delta Plugin API](https://github.com/thegail/DeltaPluginAPI)).

## Install

Using this library in your project requires that you have capstone installed on your system. Capstone can be installed using homebrew with the following command;

```sh
brew install capstone
```

The next few steps depend on what sort of project you have. Installation is different for Swift Package Manager projects and Xcode projects.

### Install - Swift Package Manager

1. Add this package as a dependency in your `Package.swift`.

Below is an example `Package.swift` with SwiftMixin as a dependency;

```swift
// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "MixinHelloWorld",
  dependencies: [
    .package(
      name: "SwiftMixin",
      url: "https://github.com/stackotter/swift-mixin",
      .branch("main"))
  ],
  targets: [
    .target(
      name: "MixinHelloWorld",
      dependencies: ["SwiftMixin"]),
    .testTarget(
      name: "MixinHelloWorldTests",
      dependencies: ["MixinHelloWorld"]),
  ]
)
```

2. Optional: Run `swift package generate-xcodeproj` because using an xcodeproj makes your life easier later on.

### Install - Xcode Project

1. Navigate to `File > Swift Packages > Add Package Dependency...`.
2. Enter `https://github.com/stackotter/swift-mixin` as the url.
3. On the next screen choose branch rule and leave the default value (it should be 'main').
4. Click next. Once it finishes loading, choose your package in the `Add to Target` column and click done.

## Final Setup

In more recent versions of macOS, Apple changed the default maxProt level of the text segment of MachO executables to be 5 (it used to be 7). In short; we need to change this value back to 7 otherwise we can't write to the memory that contains functions. I don't know which macOS version the change was made in so it's safest just to do the following steps anyway.

### Final Setup - Projects with an xcodeproj

Add a run script phase to your project containing the following;

```sh
printf '\x07' | dd of=${CONFIGURATION_BUILD_DIR}/${EXECUTABLE_PATH} bs=1 seek=160 count=1 conv=notrunc
```

This will patch the binary correctly everytime you build your project.

### Final Setup - Projects without an xcodeproj

If you have a swift package manager project and don't use a .xcodeproj then there are two options (both are not that good, it's not too late to run `swift package generate-xcodeproj`).

Option 1: Run `printf '\x07' | dd of=./path/to/compiled/binary bs=1 seek=160 count=1 conv=notrunc` everytime you build your project (an example build and run script is listed below).

RunDebug.sh
```sh
swift build
printf '\x07' | dd of=.build/debug/[PRODUCT_NAME] bs=1 seek=160 count=1 conv=notrunc
./.build/debug/[PRODUCT_NAME]
```

Option 2: Or, each time you want to build and run your project; First build and run it (you will get an error), and then run it again and it should work. Your executable will automatically patch itself, but it requires a restart of the program for the changes to take effect. This autopatching requires that your program calls `Mixin.setup()` when it starts up.

## Example Program

```swift
import SwiftMixin

func replaceMe() {
  print("Please replace me!")
}

func replacement() {
  print("Hello from the replacement!")
}

do {
  // Check that max prot is set correctly
  try Mixin.setup()
  // Create a backup of `replaceMe` so that we can still use it later
  let replaceMe_Backup = try Mixin.duplicateFunction(replaceMe)
  // Replace `replaceMe` with `replacement`
  try Mixin.replaceFunction(replaceMe, with: replacement)
  
  // Run `replaceMe` (should actually run `replacement` now)
  print("Replaced `replaceMe()`: ", terminator: "")
  replaceMe()
  
  // Run the backup
  print("Backup `replaceMe_Backup()`: ", terminator: "")
  replaceMe_Backup()
} catch {
  print("There was an error: \(error)")
}
```

## The Basics

*Coming soon*
