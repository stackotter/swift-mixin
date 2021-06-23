import Foundation
import MixinTestC

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
//    Mixin.getStructMethodAddress(TwoNumbers.sum)
    let twoNumbers = TwoNumbers(a: 9, b: 10)
    
    print("a before: \(twoNumbers.getA())")
    let sumAddress = Mixin.getStructMethodAddress(TwoNumbers.getA)
    let productAddress = Mixin.getStructMethodAddress(TwoNumbers.distanceSquared)
    overwrite_function(sumAddress, productAddress)
    print("a after: \(twoNumbers.getA())")
  } catch {
    print("Failed to install mixin: \(error)")
  }
}

main()

func runSum<T>(_ function: T) {
  let twoNumbers = TwoNumbers(a: 2, b: 3)
  if let function = function as? (TwoNumbers) -> () -> Int {
    let partiallyApplied = function(twoNumbers)
    let sum = partiallyApplied()
    print("sum: \(sum)")
  }
}
