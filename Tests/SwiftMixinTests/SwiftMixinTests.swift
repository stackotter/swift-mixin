import XCTest
@testable import SwiftMixin

final class SwiftMixinTests: XCTestCase {
  func testSimpleFunctionReplacement() throws {
    let sum = addTwoNumbers(a: 2, b: 3)
    let product = multiplyTwoNumbers(a: 2, b: 3)
    
    XCTAssertEqual(sum, 5)
    XCTAssertEqual(product, 6)
    
    let addTwoNumbers_Original = try Mixin.duplicateFunction(addTwoNumbers)
    try Mixin.replaceFunction(addTwoNumbers, with: multiplyTwoNumbers)
    
    XCTAssertEqual(addTwoNumbers(a: 2, b: 3), product)
    XCTAssertEqual(addTwoNumbers_Original(2, 3), sum)
  }
  
  func testStructMethodReplacement() throws {
    let twoNumbers = TwoNumbers(a: 2, b: 3)
    let sum = twoNumbers.sum()
    let difference = twoNumbers.difference()
    
    XCTAssertEqual(sum, 5)
    XCTAssertEqual(difference, -1)
    
    try Mixin.backupStructMethod(TwoNumbers.sum, to: TwoNumbers.sum_Original)
    try Mixin.replaceStructMethod(TwoNumbers.sum, with: TwoNumbers.difference)
    
    XCTAssertEqual(twoNumbers.sum(), difference)
    XCTAssertEqual(twoNumbers.sum_Original(), sum)
  }
  
  func testClassMethodReplacement() throws {
    let threeNumbers = ThreeNumbers(a: 1, b: 2, c: 4)
    let sum = threeNumbers.sum()
    let product = threeNumbers.product()
    
    XCTAssertEqual(sum, 7)
    XCTAssertEqual(product, 8)
    
    try Mixin.backupClassMethod(ThreeNumbers.sum, to: ThreeNumbers.sum_Original, on: ThreeNumbers.self)
    try Mixin.replaceClassMethod(ThreeNumbers.sum, with: ThreeNumbers.product, on: ThreeNumbers.self)
    
    XCTAssertEqual(threeNumbers.sum(), product)
    XCTAssertEqual(threeNumbers.sum_Original(), sum)
  }
  
  func testStaticStructMethodReplacement() throws {
    let nice = TwoNumbers.getNice()
    let evil = TwoNumbers.getEvil()
    
    XCTAssertEqual(nice, 69)
    XCTAssertEqual(evil, 666)
    
    try Mixin.backupStaticMethod(TwoNumbers.getNice, to: TwoNumbers.getNice_Original)
    try Mixin.replaceStaticMethod(TwoNumbers.getNice, with: TwoNumbers.getEvil)
    
    XCTAssertEqual(TwoNumbers.getNice(), evil)
    XCTAssertEqual(TwoNumbers.getNice_Original(), nice)
  }
  
  func testStaticClassMethodReplacement() throws {
    let pythagorean = ThreeNumbers.pythagorean()
    let consecutive = ThreeNumbers.consecutive()
    
    XCTAssertEqual(pythagorean, ThreeNumbers(a: 3, b: 4, c: 5))
    XCTAssertEqual(consecutive, ThreeNumbers(a: 1, b: 2, c: 3))
    
    try Mixin.backupStaticMethod(ThreeNumbers.pythagorean, to: ThreeNumbers.pythagorean_Original)
    try Mixin.replaceStaticMethod(ThreeNumbers.pythagorean, with: ThreeNumbers.consecutive)
    
    XCTAssertEqual(ThreeNumbers.pythagorean(), consecutive)
    XCTAssertEqual(ThreeNumbers.pythagorean_Original(), pythagorean)
  }
  
  func testEnumMethodReplacement() throws {
    let number = Number.three
    let numberAsInt = number.toInt()
    let numberAsIntTimesTen = number.toIntTimesTen()
    
    XCTAssertEqual(numberAsInt, 3)
    XCTAssertEqual(numberAsIntTimesTen, 30)
    
    try Mixin.backupEnumMethod(Number.toInt, to: Number.toInt_Original)
    try Mixin.replaceEnumMethod(Number.toInt, with: Number.toIntTimesTen)
    
    XCTAssertEqual(number.toInt(), numberAsIntTimesTen)
    XCTAssertEqual(number.toInt_Original(), numberAsInt)
  }
  
  func testStaticEnumMethodReplacement() throws {
    let favourite = Number.favourite()
    let leastFavourite = Number.leastFavourite()
    
    XCTAssertEqual(favourite, .three)
    XCTAssertEqual(leastFavourite, .two)
    
    try Mixin.backupStaticMethod(Number.favourite, to: Number.favourite_Original)
    try Mixin.replaceStaticMethod(Number.favourite, with: Number.leastFavourite)
    
    XCTAssertEqual(Number.favourite(), leastFavourite)
    XCTAssertEqual(Number.favourite_Original(), favourite)
  }

  static var allTests = [
    ("testSimpleFunctionReplacement", testSimpleFunctionReplacement),
  ]
}
