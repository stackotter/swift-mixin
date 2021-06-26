//
//  MachO.swift
//  MixinTest
//
//  Created by Rohan van Klinken on 24/6/21.
//

import Foundation

struct MachO {
  static func getMaxProt(ofExecutable executable: URL) throws -> UInt8 {
    let machoData = try Data(contentsOf: executable)
    return machoData[0xa0]
  }
  
  static func setMaxProt(ofExecutable executable: URL, to newMaxProt: UInt8) throws {
    var machoData = try Data(contentsOf: executable)
    machoData[0xa0] = newMaxProt
    try machoData.write(to: executable)
  }
}
