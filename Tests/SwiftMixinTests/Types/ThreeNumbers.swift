//
//  ThreeNumbers.swift
//  SwiftMixinTests
//
//  Created by Rohan van Klinken on 26/6/21.
//

import Foundation

class ThreeNumbers: CustomStringConvertible {
  var a: Int
  var b: Int
  var c: Int
  
  var description: String {
    return "(\(a), \(b), \(c))"
  }
  
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
  
  /// A simple static method.
  static func pythagorean() -> ThreeNumbers {
    return ThreeNumbers(a: 3, b: 4, c: 5)
  }
}

// MARK: Adding some simple replacement methods and backup dummies.
extension ThreeNumbers {
  /// A simple replacement for `sum`.
  func product() -> Int {
    return a * b * c
  }
  
  /// A dummy to backup `sum` to.
  func sum_Original() -> Int {
    return sum() // dummy
  }
  
  /// A simple replacement for `pythagorean`.
  static func consecutive() -> ThreeNumbers {
    return ThreeNumbers(a: 1, b: 2, c: 3)
  }
  
  /// A dummy to backup `pythagorean` to.
  static func pythagorean_Original() -> ThreeNumbers {
    return pythagorean()
  }
}

extension ThreeNumbers: Equatable {
  static func == (lhs: ThreeNumbers, rhs: ThreeNumbers) -> Bool {
    return lhs.a == rhs.a && lhs.b == rhs.b && lhs.c == rhs.c
  }
}
