//
//  Mixin.swift
//  MixinTest
//
//  Created by Rohan van Klinken on 21/6/21.
//

import Foundation
import MixinTestC
import Capstone

struct Mixin {
  enum MixinError: LocalizedError {
    case invalidFunction
    case invalidStructMethod
    case addWritePermissions
    case removeWritePermissions
    case invalidExecutableURL
    case getExecutablePathFailure
    case incorrectMaxProtButFixed
    case failedToCreateDisassembler
    case createPointerFailed
    case disassembleInstructionFailed
  }
  
  enum JumpOpcode: UInt8 {
    case relative8 = 0xeb
    case relative32 = 0xe9
  }
  
  enum CallOpcode: UInt8 {
    case relative32 = 0xe8
  }
  
  struct GenericFunction {
    var thunk: UInt
    var metadata: UnsafePointer<FunctionMetadata>
  }
  
  struct FunctionMetadata {
    var arg1: UInt
    var arg2: UInt
    var functionPointer: UInt
  }
  
  static let maxInstructionSize = 15
  
  static func setup() throws {
    guard let path = Bundle.main.executablePath else {
      print("Failed to get executable path (required to check maxProt of __TEXT segment")
      throw MixinError.getExecutablePathFailure
    }
    
    // Executable must have the correct max prot level set to allow WX permissions to be set for memory containing functions.
    let executable = URL(fileURLWithPath: path)
    if try Mixin.getMaxProt(ofExecutable: executable) != 0x07 {
      print("Setting max prot of executable. Restart executable for changes to take effect")
      try Mixin.setMaxProt(ofExecutable: executable, to: 0x7)
      throw MixinError.incorrectMaxProtButFixed
    }
  }
  
  static func getFunctionAddress<T>(_ function: T) -> UInt {
    var functionAddress: UInt = 0
    withUnsafePointer(to: function, { pointer in
      pointer.withMemoryRebound(to: GenericFunction.self, capacity: 1, { pointer in
        functionAddress = pointer.pointee.metadata.pointee.functionPointer
      })
    })
    return functionAddress
  }
  
  static func typeSignature<T>(of variable: T.Type) -> String {
    return String(describing: T.self)
  }
  
  static func isFunction<T>(_ potentialFunction: T) -> Bool {
    // check the function's type's string representation for '->'
    let signature = typeSignature(of: T.self)
    return signature.split(separator: " ").contains("->")
  }
  
  static func isStructMethod<T>(_ potentialFunction: T) -> Bool {
    // check the function's type's string representation for '->'
    let signature = typeSignature(of: T.self)
    let arrows = signature.split(separator: " ").filter { $0 == "->" }
    return arrows.count == 2 // TODO: find a better way to check for struct methods
  }
  
  static func replaceFunction<T>(_ function: T, with replacement: T) throws {
    // Check function to replace is actually a function
    guard isFunction(T.self) else {
      print("Generic type T must be a function")
      throw MixinError.invalidFunction
    }
    
    let functionAddress = getFunctionAddress(function)
    let replacementAddress = getFunctionAddress(replacement)
    print(String(format: "Replacing function at 0x%lx with function at 0x%lx", functionAddress, replacementAddress))
    
    let result = overwrite_function(functionAddress, replacementAddress)

    switch result {
      case -1:
        print("Failed to add write permissions to function memory")
        throw MixinError.addWritePermissions
      case -2:
        print("Failed to remove write permissions from function memory (non-fatal)")
        throw MixinError.removeWritePermissions
      default:
        return
    }
  }
  
  static func replaceStructMethod<T>(_ method: T, with replacement: T) throws {
    print(typeSignature(of: T.self))

    let methodAddress = getStructMethodAddress(method)
    let replacementAddress = getStructMethodAddress(replacement)
    overwrite_function(methodAddress, replacementAddress)

    if let method = method as? () -> Int {
      let sum = method()
      print("sum: \(sum)")
    }
  }
  
  static func getStructMethodAddress<T>(_ method: T) -> UInt {
    // getFunctionAddress just happens to be what we need to get the address of the part of the function that returns an address to the actual method implementation
    let thunkAddressGetterThunk = getFunctionAddress(method)
    let implicitClosurePartialApplyThunk = run_void_to_uint64_function(thunkAddressGetterThunk)
    print(String(format: "Implicit closure partial apply thunk: 0x%lx", implicitClosurePartialApplyThunk))
    
    let popRBPOpcode: UInt8 = 0x5d
    
    var address = implicitClosurePartialApplyThunk
    if let thunkPointer = UnsafePointer<UInt8>(bitPattern: implicitClosurePartialApplyThunk) {
      var previousByte = thunkPointer.pointee
      var i = 1
      while true { // TODO: fix this, this is dangerous
        let byte = thunkPointer.advanced(by: i).pointee
        
        if previousByte == popRBPOpcode, let jump = JumpOpcode(rawValue: byte) {
          switch jump {
            case .relative8:
              address += UInt(i) + 2 // the end of the jump instruction
              thunkPointer.advanced(by: i+1).withMemoryRebound(to: Int8.self, capacity: 1, {
                let offset = $0.pointee
                let absoluteOffset = UInt(UInt8(abs(offset)))
                if offset < 0 {
                  address -= absoluteOffset
                } else if offset > 0 {
                  address += absoluteOffset
                }
              })
            case .relative32:
              address += UInt(i) + 5 // the end of the jump instruction
              thunkPointer.advanced(by: i+1).withMemoryRebound(to: Int32.self, capacity: 1, {
                let offset = $0.pointee
                let absoluteOffset = UInt(UInt32(abs(offset)))
                if offset < 0 {
                  address -= absoluteOffset
                } else if offset > 0 {
                  address += absoluteOffset
                }
              })
          }
          break
        }
        
        previousByte = byte
        i += 1
      }
      
      if let thunkPointer = UnsafePointer<UInt8>(bitPattern: address) {
        var i = 0
        while true {
          if thunkPointer.advanced(by: i).pointee == 0xe8,
             thunkPointer.advanced(by: i+5).pointee == 0x48,
             thunkPointer.advanced(by: i+6).pointee == 0x83,
             thunkPointer.advanced(by: i+7).pointee == 0xc4,
             thunkPointer.advanced(by: i+9).pointee == 0x5d,
             thunkPointer.advanced(by: i+10).pointee == 0xc3 {
            address += UInt(i) + 5
            thunkPointer.advanced(by: i+1).withMemoryRebound(to: Int32.self, capacity: 1, {
              let offset = $0.pointee
              let absoluteOffset = UInt(UInt32(abs(offset)))
              if offset < 0 {
                address -= absoluteOffset
              } else if offset > 0 {
                address += absoluteOffset
              }
            })
            break
          }
          i += 1
        }
      }
    }
    
    return address
  }
  
  static func getLength(ofFunctionAt address: UInt) throws -> UInt {
    guard let disassembler = try? Capstone(arch: .x86, mode: [Mode.bits.b64]) else {
      throw MixinError.failedToCreateDisassembler
    }
    
    var offset: UInt = 0
    while true {
      guard let pointer = UnsafeRawPointer(bitPattern: address + offset) else {
        throw MixinError.createPointerFailed
      }
      
      let data = Data(bytes: pointer, count: maxInstructionSize)
      
      guard let instruction: X86Instruction = try disassembler.disassemble(code: data, address: UInt64(address), count: 1).first else {
        throw MixinError.disassembleInstructionFailed
      }
      
      offset += UInt(instruction.size)
      
      if instruction.bytes[0] == 0xc3 { // ret
        break
      }
    }
    
    return offset
  }

  
//  static func duplicateFunction<T>(_ function: T) -> T {
//    withUnsafePointer(to: function, { pointer in
//      pointer.withMemoryRebound(to: GenericFunction.self, capacity: 1, { pointer in
//        let functionAddress = getFunctionAddress(function)
//        UnsafeMutablePointer(mutating: pointer.pointee.metadata).pointee.functionPointer = duplicate_function(functionAddress)
//      })
//    })
//    return function
//  }
  
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
