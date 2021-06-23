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
  
  init(a: Int, b: Int) {
    self.a = a
    self.b = b
  }
  
  func getA() -> Int {
    return a
  }
  
  func sum() -> Int {
    return a + b
  }
  
  func difference() -> Int {
    return a - b
  }
}
