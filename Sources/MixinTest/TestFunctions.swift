//
//  TestFunctions.swift
//  MixinTest
//
//  Created by Rohan van Klinken on 21/6/21.
//

import Foundation

// MARK: simple () -> () functions

func functionToReplace() {
  print("Replace me")
}

func replacementFunction() {
  print("This is the replacement")
}

// MARK: functions with parameters and a return value

func add(a: Int, b: Int) -> Int {
  return a + b
}

func multiply(a: Int, b: Int) -> Int {
  return a * b
}

// MARK: fake instance methods

func difference(_ self: TwoNumbers) -> () -> Int {
  return {
    return self.a - self.b
  }
}

func productPlusOne(_ self: TwoNumbers) -> () -> Int {
  return {
    return self.a * self.b + 1
  }
}

// MARK: simple methods on a struct

struct TwoNumbers {
  var a: Int
  var b: Int
  
  func sum() -> Int {
    return a + b
  }
  
  static func getNice() -> Int {
    return 69
  }
}

class ThreeNumbers {
  var a: Int
  var b: Int
  var c: Int
  
  init(a: Int, b: Int, c: Int) {
    self.a = a
    self.b = b
    self.c = c
  }
  
  func sum() -> Int {
    return a + b + c
  }
}

enum Numbers {
  case one
  case two
  case three
  
  func getDecimalRepresentation() -> Int {
    switch self {
      case .one:
        return 1
      case .two:
        return 2
      case .three:
        return 3
    }
  }
}
