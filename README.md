# SwiftMixin

> Disclaimer: This package is very young and due to its nature, a small change to the swift compiler could brick this package. I will try my best to fix issues as fast as I can but this probably shouldn't be used in a production app.

## Quick Overview

SwiftMixin provides all of the functionality required to overwrite functions and methods at runtime. It also allows you to create backups of functions before you overwrite them so that you can still use the original function. This package was made for a Swift plugin system ([Delta Plugin API](https://github.com/thegail/DeltaPluginAPI)).

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

Due to differences in compilation, different types of functions/methods are treated differently so it is important to make a few clear distinctions;

1. A function is **NOT** attached to any struct, enum or class.
2. A method **IS** attached to a struct, enum or class.
3. Class methods and struct methods act differently under the hood.
4. Struct methods and enum methods work the same under the hood.
5. Static functions work the same way under the hood for structs, enums and classes.

SwiftMixin provides two main lines of functionality. Replacing functions/methods and 'duplicating' functions/methods. Duplicating does not duplicate the entire function it just duplicates the part that SwiftMixin replaces when told to replace a function. This is enough to allow calling the original function even after it is replaced.

### Setting up a mixin environment

Each time your app starts it should check that it's memory protection bit it correctly patched. This sounds scary but SwiftMixin makes it easy. Just add the following line to your app's startup;

```swift
try Mixin.setup()
```

This will automatically check your executable's text segment's maximum protection level (should be 7 but is 5 by default). If the protection level is not set correctly the executable will patch itself and `Mixin.setup()` will throw an error. The next time the executable is run it should work properly.

### Working With Functions

Let's consider the following two functions;

```swift
func sum(a: Int, b: Int) -> Int {
  return a + b
}

func product(a: Int, b: Int) -> Int {
  return a * b
}
```

If we want to replace `sum` with `product` we can use the following line of code. Xcode will try to autocomplete these to calls to sum and product but make sure you are just passing the function as if it were a variable.

```swift
try Mixin.replaceFunction(sum, with: product)
```

Now when we rum `sum(a: 2, b: 3)` we will get 6 instead of 5.

Now consider the following function;

```swift
func sumPlusOne(a: Int, b: Int) -> Int {
  return sum(a: a, b: b) + 1
}
```

We really don't like repeating code (let's just ignore that using `sum` is longer than `a + b`), but what happens now if we try to replace `sum` with `sumPlusOne`. Well, we'll cause an infinite loop, and although that sounds fun, it's not very useful. What we need to do is create a copy of `sum` and use that instead. Replace your declaration of `sumPlusOne` with the following;

```swift
let sum_Original = try Mixin.duplicateFunction(sum)

func sumPlusOne(a: Int, b: Int) -> Int {
  return sum_Original(a, b) + 1
}
```

Notice that sum_Original does not have any parameter labels, this is just how SwiftMixin has to work when duplicating functions. Now when we replace `sum` with `sumPlusOne`, `sum(a: 4, b: 5)` will return 10 (yeah, I know, it's very useful).

### Working With Structs, Enums and Classes (excluding static methods)

In the `Working With Functions` section I explained the basics. I'll start going a bit faster now.

Please note: replacement methods must be on the same struct, class or enum as the method to replace. This is achieved using extensions (because If you can edit the actual struct, enum or class definition then there is probably a better solution than mixins.

Also, to back up methods we create a dummy method usually named `methodName_Original` and then overwrite it with a copy of the function we are backing up. This allows us to call the original method from our replacement or even elsewhere in our code.

Using SwiftMixin is pretty similar for structs, enums and classes but there are some subtle differences.

### Struct Methods

Consider the following struct;

```swift
/// A simple struct for testing replacements and backups on.
struct TwoNumbers {
  var a: Int
  var b: Int
  
  /// A simple method.
  func sum() -> Int {
    return a + b
  }
}

// MARK: Adding some simple replacement methods and backup dummies.
extension TwoNumbers {
  /// A simple replacement for `sum`.
  func difference() -> Int {
    return a - b
  }
  
  /// A dummy to backup `sum` to.
  func sum_Original() -> Int {
    return sum() // dummy
  }
}
```

Notice how the replacement and backup are added in an extension, this is likely how you'll want to replace methods because it you can just edit the source code then you don't need to use this package. To replace `TwoNumbers.sum` with `TwoNumbers.difference` run the following line;

```swift
try Mixin.replaceStructMethod(TwoNumbers.sum, with: TwoNumbers.difference)
```

To create a backup of `TwoNumbers.sum` we'll overwrite `TwoNumbers.sum_Original` to be a backup;

```swift
try Mixin.backupStructMethod(TwoNumbers.sum, to: TwoNumbers.sum_Original)
```

Pretty straightforward right?

### Enum Methods

Pretty much the same as struct methods just replace Struct with Enum;

```swift
enum FlightId {
  // ...
  
  func toInt() -> Int {
    // ...
  }
}

extension FlightId {
  func toIntTimesTen() -> Int {
    return toInt_Original() * 10
  }
  
  func toInt_Original() -> Int {
    fatalError("Don't forget to backup toInt")
  }  
}

// Backing up a method
try Mixin.backupEnumMethod(FlightId.toInt, to: FlightId.toInt_Original)
// Replacing toInt with toIntTimesTen
try Mixin.replaceEnumMethod(FlightId.toInt, with: FlightId.toIntTimesTen)
```

### Class Methods

The only difference from structs and enums is that you need to also pass the metatype of the class that you're doing stuff on because of how class methods work. For example;

```swift
class ThreeNumbers {
  var a: Int
  var b: Int
  var c: Int
  
  /// A simple member-wise initializer.
  init(a: Int, b: Int, c: Int) {
    self.a = a
    self.b = b
    self.c = c
  }
  
  /// A simple instance method.
  func sum() -> Int {
    return a + b + c
  }
}

extension ThreeNumbers {
  /// A dummy to backup `sum` to.
  func sum_Original() -> Int {
    fatalError("someone forgot to backup ThreeNumbers.sum")
  }
  
  /// A method to replace `sum` with.
  func product() -> Int {
    return a + b + c
  }
}

// Backing up `sum` to `sum_Original`
try Mixin.backupClassMethod(ThreeNumbers.sum, to: ThreeNumbers.sum_Original, on: ThreeNumbers.self)
// Replacing `sum` with `product`
try Mixin.replaceClassMethod(ThreeNumbers.sum, with: ThreeNumbers.product, on: ThreeNumbers.self)
```

### Static Methods

Static methods are the same for structs, enums and classes.

Here's an example of backing up and replacing a static method on a struct;

```swift
struct HandyNumbers {
  // A simple static method
  static func getPalindrome() -> Int {
    return 121
  }
}

extension HandyNumbers {
  /// A simple static method to replace `getPalindrome` with (it's also a palindrome!)
  static func getEvil() -> Int {
    return 666
  }
  
  static func getPalindrome_Original() -> Int {
    fatalError("You forgot to unstack the dishwasher")
  }
}

// Backing up `getPalindrome` to `getPalindrome_Original`
try Mixin.backupStaticMethod(HandyNumbers.getPalindrome, to: HandyNumbers.getPalindrome_Original)
// Replacing `getPalindrome` with `getEvil`
try Mixin.replaceStaticMethod(HandyNumbers.getPalindrome, with: HandyNumbers.getEvil)
```

## Limitations

1. Replacing initializers doesn't work yet.
2. Replacing getters and setters is also not supported yet, I have some ideas for approaching them but I will not be working on this again for a little while.
3. If the Swift compiler changes too much, this breaks.
