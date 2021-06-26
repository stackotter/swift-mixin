//
//  Disassembler.swift
//  SwiftMixin
//
//  Created by Rohan van Klinken on 24/6/21.
//

import Foundation
import Capstone

enum DisassemblerError: LocalizedError {
  case pointerError
  case noInstruction
}

struct Disassembler {
  static let maxInstructionLength = 15
  
  private let capstone: Capstone
  var address: UInt
  
  var offset: UInt = 0
  
  init(forFunctionAt address: UInt) throws {
    self.address = address
    capstone = try Capstone(arch: .x86, mode: Mode.bits.b64)
    try capstone.set(option: .detail(value: true))
  }
  
  mutating func next<T: Instruction>() throws -> T {
    guard let pointer = UnsafeRawPointer(bitPattern: address + offset) else {
      throw DisassemblerError.pointerError
    }
    
    let data = Data(bytes: pointer, count: Self.maxInstructionLength)
    let instructions: [T] = try capstone.disassemble(code: data, address: UInt64(address + offset), count: 1)
    
    guard let instruction = instructions.first else {
      throw DisassemblerError.noInstruction
    }
    
    offset += UInt(instruction.size)
    return instruction
  }
}
