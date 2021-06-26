//
//  Number.swift
//  SwiftMixinTests
//
//  Created by Rohan van Klinken on 26/6/21.
//

import Foundation

enum Number {
  case one
  case two
  case three
  
  /// A simple method.
  func toInt() -> Int {
    switch self {
      case .one:
        return 1
      case .two:
        return 2
      case .three:
        return 3
    }
  }
  
  static func favourite() -> Number {
    return .three
  }
}

// MARK: Adding some simple replacement methods and backup dummies.
extension Number {
  /// A simple (and terrible) replacement for `toInt`.
  func toIntTimesTen() -> Int {
    return toInt_Original() * 10
  }
  
  /// A dummy to backup toInt to. `toIntTimesTen` uses this.
  func toInt_Original() -> Int {
    // TODO: consider what the best practice should be for the contents of a backup
    // most likely it should either be returning a call to the original but that's
    // annoying with more arguments. Maybe a fatalError would be better (also a good
    // reminder if you forget to create the backup or the backup fails.
    return toInt()
  }
  
  /// A simple replacement for `favourite` (ew).
  static func leastFavourite() -> Number {
    return .two
  }
  
  /// A dummy to backup `favourite` to.
  static func favourite_Original() -> Number {
    return favourite()
  }
}
