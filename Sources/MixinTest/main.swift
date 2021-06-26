import Foundation
import MixinTestC
import Capstone

/// Replacements that are currently working
func workingTests() throws {
  // Testing a replacement of a simple () -> ()
  print("Replacing a functionToReplace() with replacementFunction()")
  print("Before : ", terminator: "")
  functionToReplace()
  let backup = try Mixin.duplicateFunction(functionToReplace)
  try Mixin.replaceFunction(functionToReplace, with: replacementFunction)
  print("After : ", terminator: "")
  functionToReplace()
  print("Backup: ", terminator: "")
  backup()
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
  try Mixin.backupStructMethod(TwoNumbers.sum, to: TwoNumbers.sum_Original)
  try Mixin.replaceStructMethod(TwoNumbers.sum, with: TwoNumbers.difference)
  print("twoNumbers.sum() after: \(twoNumbers.sum())")
  print("twoNumbers.sum() backup: \(twoNumbers.sum_Original())")
  print("")
  
  // Testing replacement and backing up of an enum method
  let number = Numbers.three
  print("number.getDecimalRepresentation() before: \(number.getDecimalRepresentation())")
  try Mixin.backupStructMethod(Numbers.getDecimalRepresentation, to: Numbers.getDecimalRepresentation_Original)
  try Mixin.replaceStructMethod(Numbers.getDecimalRepresentation, with: Numbers.getDecimalRepresentationTimesTen)
  print("number.getDecimalRepresentation() after : \(number.getDecimalRepresentation())")
  print("number.getDecimalRepresentation() backup: \(number.getDecimalRepresentation_Original())")
  
  // Testing replacement and backing up of a class method
  let threeNumbers = ThreeNumbers(a: 1, b: 2, c: 4)
  print("threeNumbers.sum() before: \(threeNumbers.sum())")
  try Mixin.backupClassMethod(ThreeNumbers.sum, to: ThreeNumbers.sum_Original, on: ThreeNumbers.self)
  try Mixin.replaceClassMethod(ThreeNumbers.sum, with: ThreeNumbers.product, on: ThreeNumbers.self)
  print("threeNumbers.sum() after : \(threeNumbers.sum())")
  print("threeNumbers.sum() backup: \(threeNumbers.sum_Original())")
  
  // Testing replacement and backing up of static struct method
  print("nice before: \(TwoNumbers.getNice())")
  try Mixin.backupStaticMethod(TwoNumbers.getNice, to: TwoNumbers.getNice_Original)
  try Mixin.replaceStaticMethod(TwoNumbers.getNice, with: TwoNumbers.getEvil)
  print("nice after : \(TwoNumbers.getNice())")
  print("nice backup: \(TwoNumbers.getNice_Original())")
  
  // Testing replacement and backing up of static class method
  print("pythagorean before: \(ThreeNumbers.pythagorean())")
  try Mixin.backupStaticMethod(ThreeNumbers.pythagorean, to: ThreeNumbers.pythagorean_Original)
  try Mixin.replaceStaticMethod(ThreeNumbers.pythagorean, with: ThreeNumbers.consecutive)
  print("pythagorean after : \(ThreeNumbers.pythagorean())")
  print("pythagorean backup: \(ThreeNumbers.pythagorean_Original())")
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
    
  } catch {
    print("Something to do with mixins failed: \(error)")
  }
}

main()
