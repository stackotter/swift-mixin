//
//  MachO.swift
//  SwiftMixin
//
//  Created by Rohan van Klinken on 24/6/21.
//

import Foundation

enum MachOError: LocalizedError {
  case getExecutablePathFailure
}

struct MachO {
  fileprivate init() { }
  
  static func getExecutablePath() throws -> URL {
    guard let path = Bundle.main.executablePath else {
      print("Failed to get executable path (required to check maxProt of __TEXT segment")
      throw MachOError.getExecutablePathFailure
    }
    return URL(fileURLWithPath: path)
  }
  
  static func getMaxProt() throws -> UInt8 {
    let executable = try getExecutablePath()
    return try getMaxProt(of: executable)
  }
  
  static func setMaxProt(to newMaxProt: UInt8) throws {
    let executable = try getExecutablePath()
    try setMaxProt(of: executable, to: newMaxProt)
  }
  
  static func getMaxProt(of executable: URL) throws -> UInt8 {
    let machoData = try Data(contentsOf: executable)
    return machoData[0xa0]
  }
  
  static func setMaxProt(of executable: URL, to newMaxProt: UInt8) throws {
    var machoData = try Data(contentsOf: executable)
    machoData[0xa0] = newMaxProt
    try machoData.write(to: executable)
  }
}
