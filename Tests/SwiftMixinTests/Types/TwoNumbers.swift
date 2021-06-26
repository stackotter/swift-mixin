//
//  TwoNumbers.swift
//  SwiftMixinTests
//
//  Created by Rohan van Klinken on 26/6/21.
//

import Foundation

/// A simple struct for testing replacements and backups on.
struct TwoNumbers {
  var a: Int
  var b: Int
  
  /// A simple method.
  func sum() -> Int {
    return a + b
  }
  
  /// A simple static method.
  static func getNice() -> Int {
    return 69
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
  
  /// A simple replacement for `getNice`.
  static func getEvil() -> Int {
    return 666
  }
  
  /// A dummy to backup `getNice` to.
  static func getNice_Original() -> Int {
    return getNice()
  }
}
