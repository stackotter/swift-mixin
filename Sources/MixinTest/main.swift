import Foundation
import MixinTestC
import Capstone

/// Replacements that are currently working
func workingTests() throws {
  // Testing a replacement of a simple () -> ()
  print("Replacing a functionToReplace() with replacementFunction()")
  print("Before : ", terminator: "")
  functionToReplace()
  try Mixin.replaceFunction(functionToReplace, with: replacementFunction)
  print("After : ", terminator: "")
  functionToReplace()
  print("")
  
  // Testing replacement of a function with parameters and a return
  print("Replacing add(a:b:) with multiply(a:b:)")
  print("Before : 2 + 3 = \(add(a: 2, b: 3))")
  try Mixin.replaceFunction(add, with: multiply)
  print("After  : 2 + 3 = \(add(a: 2, b: 3))")
  print("")
  
  // Testing replacement of a struct method with a method from an extension
  let twoNumbers = TwoNumbers(a: 9, b: 10)
  print("twoNumbers.sum() before: \(twoNumbers.sum())")
  let sumAddress = Mixin.getStructMethodAddress(TwoNumbers.sum)
  let productAddress = Mixin.getStructMethodAddress(TwoNumbers.distanceSquared)
  overwrite_function(sumAddress, productAddress)
  print("twoNumbers.sum() after: \(twoNumbers.sum())")
}

extension TwoNumbers {
  func distanceSquared() -> Int {
    return a*a + b*b
  }
}

// MARK: main

func main() {
  do {
    try Mixin.setup()
  } catch {
    print("Failed to setup mixins: \(error)")
    return
  }
  
  do {
//    print("Replacing add(a:b:) with multiply(a:b:)")
//    print("Before (2 + 3): \(add(a: 2, b: 3))")
//    let original = Mixin.duplicateFunction(add)
//    try Mixin.replaceFunction(add, with: multiply)
//    print("After  (2 * 3): \(add(a: 2, b: 3))")
//    print("Backup (2 + 3): \(original(2, 3))")
    
    let functionAddress = Mixin.getStructMethodAddress(TwoNumbers.sum)
    let length = try Mixin.getLength(ofFunctionAt: functionAddress)
    print("sum length: \(length)")
  } catch {
    print("Something to do with mixins failed: \(error)")
  }
}

main()
