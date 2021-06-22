//
//  Mixin.swift
//  MixinTest
//
//  Created by Rohan van Klinken on 21/6/21.
//

import Foundation
import MixinTestC

struct Mixin {
  enum MixinError: LocalizedError {
    case invalidFunction
    case invalidStructMethod
    case addWritePermissions
    case removeWritePermissions
    case invalidExecutableURL
    case getExecutablePathFailure
    case incorrectMaxProtButFixed
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
  
  static func setup() throws {
    guard let path = Bundle.main.executablePath else {
      print("Failed to get executable path (required to check maxProt of __TEXT segment")
      throw MixinError.getExecutablePathFailure
    }
    
    // Executable must have the correct max prot level set to allow WX permissions to be set for memory containing functions.
    let executable = URL(fileURLWithPath: path)
    if try Mixin.getMachoMaxProt(ofExecutable: executable) != 0x07 {
      print("Setting max prot of executable. Restart executable for changes to take effect")
      try Mixin.setMachoMaxProt(ofExecutable: executable, to: 0x7)
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

    let methodAddress = getFunctionAddress(method)
    let replacementAddress = getFunctionAddress(replacement)
    print(String(format: "Replacing method at 0x%lx with method at 0x%lx", methodAddress, replacementAddress))

    if let method = method as? () -> Int {
      let sum = method()
      print("sum: \(sum)")
    }
  }
  
  static func getStructMethodAddress<T>(_ method: T) {
    // getFunctionAddress just happens to be what we need to get the address of the part of the function that returns an address to the actual method implementation
    let thunkAddressGetterThunk = getFunctionAddress(method)
    let implicitClosurePartialApplyThunk = run_void_to_uint64_thunk(thunkAddressGetterThunk)
    print(String(format: "Implicit closure partial apply thunk: 0x%lx", implicitClosurePartialApplyThunk))
    
  }
  
  static func getMachoMaxProt(ofExecutable executable: URL) throws -> UInt8 {
    let machoData = try Data(contentsOf: executable)
    return machoData[0xa0]
  }
  
  static func setMachoMaxProt(ofExecutable executable: URL, to newMaxProt: UInt8) throws {
    var machoData = try Data(contentsOf: executable)
    machoData[0xa0] = newMaxProt
    try machoData.write(to: executable)
  }
}
