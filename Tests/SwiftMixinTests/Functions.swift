//
//  Functions.swift
//  SwiftMixinTests
//
//  Created by Rohan van Klinken on 26/6/21.
//

import Foundation

/// A very simple function.
func functionToReplace() {
  print("Replace me")
}

/// A pretty simple function with two parameters and a return.
func addTwoNumbers(a: Int, b: Int) -> Int {
  return a + b
}

// MARK: Some simple replacement functions.

/// A very simple replacement for `functionToReplace`
func replacementFunction() {
  print("This is the replacement")
}

/// A simple (and terrible) replacement for `add`.
func multiplyTwoNumbers(a: Int, b: Int) -> Int {
  return a * b
}
