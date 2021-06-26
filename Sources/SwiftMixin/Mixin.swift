//
//  Mixin.swift
//  SwiftMixin
//
//  Created by Rohan van Klinken on 21/6/21.
//

import Foundation
import SwiftMixinC
import Capstone

enum MixinError: LocalizedError {
  case invalidFunction
  case addWritePermissions
  case removeWritePermissions
  case incorrectMaxProtButFixed
  case failedToCreateDisassembler
  case createPointerFailed
  case disassembleInstructionFailed
  case invalidJump
  case invalidCall
}

// TODO: overwrite functions from swift instead of c if possible.
// TODO: reduce the amount of c code.
// TODO: get duplicating a function working.

public struct Mixin {
  private struct GenericFunction {
    var thunk: UInt
    var metadata: UnsafePointer<FunctionMetadata>
  }
  
  private struct FunctionMetadata {
    var arg1: UInt
    var arg2: UInt
    var functionPointer: UInt
  }
  
  private static let maxInstructionSize = 15
  private static let thunkSize = 5

  fileprivate init() { }
  
  /// Sets up and checks the mixin environment for this executable.
  public static func setup() throws {
    // Executable must have the correct max prot level set to allow write and execute for function memory
    if try MachO.getMaxProt() != 0x07 {
      print("Setting max prot of executable. Restart executable for changes to take effect")
      try MachO.setMaxProt(to: 0x7)
      throw MixinError.incorrectMaxProtButFixed
    }
  }
  
  /// For a function this returns the address of the function.
  /// For a method it returns the address of the partially applied method.
  private static func implicitClosure<T>(of function: T) -> UInt {
    var address: UInt = 0
    withUnsafePointer(to: function, { pointer in
      pointer.withMemoryRebound(to: GenericFunction.self, capacity: 1, { pointer in
        address = pointer.pointee.metadata.pointee.functionPointer
      })
    })
    return address
  }
  
  private static func typeSignature<T>(of variable: T.Type) -> String {
    return String(describing: T.self)
  }
  
  /// Checks if a value is a function. Relies on only function type signatures containing arrows (`->`).
  private static func isFunction<T>(_ potentialFunction: T) -> Bool {
    // check the function's type's string representation for '->'
    let signature = typeSignature(of: T.self)
    return signature.split(separator: " ").contains("->")
  }
  
  /// Returns the address of the given function.
  public static func getFunctionAddress<T>(of function: T) -> UInt {
    return implicitClosure(of: function)
  }
  
  /// Replaces a function with another function. Does NOT work for struct/class methods
  public static func replaceFunction<T>(_ function: T, with replacement: T) throws {
    guard isFunction(T.self) else {
      throw MixinError.invalidFunction
    }
    
    let functionAddress = implicitClosure(of: function)
    let replacementAddress = implicitClosure(of: replacement)
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
  
  /// Returns the address of a struct method.
  public static func getStructMethodAddress<T>(_ method: T) throws -> UInt {
    let implicitClosureAddress = implicitClosure(of: method)
    let nestedImplicitClosureAddress = run_void_to_uint64_function(implicitClosureAddress)
    let methodAddress = try getStructMethodAddress(fromNestedImplicitClosureAt: nestedImplicitClosureAddress)
    return methodAddress
  }
  
  private static func getStructMethodAddress(fromNestedImplicitClosureAt nestedImplicitClosureAddress: UInt) throws -> UInt {
    // TODO: fix variable naming to be more correct
    // Find the address that the partial apply forwarder jumps to (the address of the next implicit closure)
    var disassembler = try Disassembler(forFunctionAt: nestedImplicitClosureAddress)
    var partiallyApplied: UInt = 0
    while true {
      let instruction: X86Instruction = try disassembler.next()
      if instruction.isIn(group: .jump) {
        let hexString = instruction.operandsString.dropFirst(2)
        guard let address = UInt(hexString, radix: 16) else {
          print(instruction.description)
          throw MixinError.invalidJump
        }
        partiallyApplied = address
        break
      }
    }
    
    // Find the address that the closure calls (the address of the actual function)
    disassembler = try Disassembler(forFunctionAt: partiallyApplied)
    var methodAddress: UInt = 0
    while true {
      let instruction: X86Instruction = try disassembler.next()
      if instruction.isIn(group: .call) {
        let hexString = instruction.operandsString.dropFirst(2)
        guard let address = UInt(hexString, radix: 16) else {
          print(instruction.description)
          throw MixinError.invalidCall
        }
        methodAddress = address
        break
      }
    }
    
    return methodAddress
  }
  
  /// Replaces a struct's method with another method. Both methods must be on the same struct.
  public static func replaceStructMethod<T>(_ method: T, with replacement: T) throws {
    // TODO: check both methods are on the same struct.
    
    let methodAddress = try getStructMethodAddress(method)
    let replacementAddress = try getStructMethodAddress(replacement)
    overwrite_function(methodAddress, replacementAddress)
  }
  
  /// Replaces an enum's method with another method. Both methods must be on the same enum.
  public static func replaceEnumMethod<T>(_ method: T, with replacement: T) throws {
    try replaceStructMethod(method, with: replacement)
  }
  
  /// Replaces a struct's method with another method. Both methods must be on the same struct.
  public static func replaceClassMethod<T1, T2>(_ method: T1, with replacement: T1, on type: T2.Type) throws {
    let methodAddress = try getClassMethodAddress(of: method, onType: type)
    let replacementAddress = try getClassMethodAddress(of: replacement, onType: type)
    overwrite_function(methodAddress, replacementAddress)
  }
  
  /// Returns the length of a function in bytes. This relies on a function's compiled form only
  /// having one `ret` instruction which seems to always be true.
  private static func getLength(ofFunctionAt address: UInt) throws -> UInt {
    var disassembler = try Disassembler(forFunctionAt: address)
    
    while true {
      let instruction = try disassembler.next()
      if instruction.bytes[0] == 0xc3 { // ret
        break
      }
    }
    
    return disassembler.offset
  }
  
  /// Returns a duplicate of the specified function so that it can be called even when
  /// the original is replaced.
  public static func duplicateFunction<T>(_ function: T) throws -> T {
    let address = getFunctionAddress(of: function)
    let duplicateAddress = try duplicateFunction(at: address)
    withUnsafePointer(to: function, { pointer in
      pointer.withMemoryRebound(to: GenericFunction.self, capacity: 1, { pointer in
        let metadataPointer = UnsafeMutablePointer(mutating: pointer.pointee.metadata)
        metadataPointer.pointee.functionPointer = duplicateAddress
      })
    })

    return function
  }
  
  /// Creates a thunk that allows a function to still be called even after it is replaced.
  private static func duplicateFunction(at address: UInt) throws -> UInt {
    var disassembler = try Disassembler(forFunctionAt: address)
    while disassembler.offset < thunkSize {
      _ = try disassembler.next()
    }
    let numBytesToCopy = disassembler.offset
    let duplicateAddress = duplicate_function(address, numBytesToCopy)
    return duplicateAddress
  }
  
  /// Overwrites the destination method to be a backup that can be called to invoke the original function
  /// even after the original is replaced.
  public static func backupStructMethod<T>(_ method: T, to destination: T) throws {
    // TODO: check that the methods are both on the same struct
    
    let methodAddress = try getStructMethodAddress(method)
    let destinationAddress = try getStructMethodAddress(destination)
    let backup = try duplicateFunction(at: methodAddress)
    
    overwrite_function(destinationAddress, backup)
  }
  
  /// Overwrites the destination method to be a backup that can be called to invoke the original function
  /// even after the original is replaced.
  public static func backupEnumMethod<T>(_ method: T, to destination: T) throws {
    try backupStructMethod(method, to: destination)
  }
  
  /// Overwrites the destination method to be a backup that can be called to invoke the original function
  /// even after the original is replaced. Both methods must be on the specified type
  public static func backupClassMethod<T1, T2>(_ method: T1, to destination: T1, on type: T2.Type) throws {
    // TODO: check that the methods are both on the same class
    
    let methodAddress = try getClassMethodAddress(of: method, onType: type)
    let destinationAddress = try getClassMethodAddress(of: destination, onType: type)
    let backupAddress = try duplicateFunction(at: methodAddress)
    
    overwrite_function(destinationAddress, backupAddress)
  }
  
  /// Returns the actual address of the specified method on the specified class. Both the
  /// method and the class have to be specified because of the inner workings of swift.
  public static func getClassMethodAddress<T1, T2>(of method: T1, onType type: T2.Type) throws -> UInt {
    // Get the address of the class's metadata
    var classMetadataAddress: UInt = 0
    withUnsafePointer(to: type, { pointer in
      pointer.withMemoryRebound(to: UInt.self, capacity: 1, { pointer in
        classMetadataAddress = pointer.pointee
      })
    })
    
    // The method is located at an offset in the class's metadata when the method is not in an extension.
    // If the method is from an extension then getting its address is more similar to struct methods.
    
    // Get the address of the partial apply forwarder (a thunk)
    let implicitClosureAddress = implicitClosure(of: method)
    var disassembler = try Disassembler(forFunctionAt: implicitClosureAddress)
    var partialApplyForwarder: UInt = 0
    while true {
      let instruction: X86Instruction = try disassembler.next()
      if instruction.opcode[0] == 0x8d { // lea
        var offset: UInt32 = 0
        withUnsafePointer(to: instruction.bytes.advanced(by: 3), { pointer in
          pointer.withMemoryRebound(to: UInt32.self, capacity: 1, { pointer in
            offset = pointer.pointee
          })
        })
        partialApplyForwarder = UInt(disassembler.address + disassembler.offset) + UInt(instruction.size) + UInt(offset)
        break
      }
    }
    
    // Find the address that the partial apply forwarder jumps to (the address of the next implicit closure)
    disassembler = try Disassembler(forFunctionAt: partialApplyForwarder)
    var nestedImplicitClosure: UInt = 0
    while true {
      let instruction: X86Instruction = try disassembler.next()
      if instruction.isIn(group: .jump) {
        let hexString = instruction.operandsString.dropFirst(2)
        guard let address = UInt(hexString, radix: 16) else {
          print(instruction.description)
          throw MixinError.invalidJump
        }
        nestedImplicitClosure = address
        break
      }
    }
    
    // There are two different ways a class method is called.
    // Its address is either;
    // 1. stored at an offset in the class's metadata
    // 2. hardcoded into the implicit closure if the method is from an extension
    
    // In both cases the important instruction is at offset 22
    disassembler = try Disassembler(forFunctionAt: nestedImplicitClosure + 22)
    let instruction: X86Instruction = try disassembler.next()
    var methodAddress: UInt = 0
    if instruction.opcode[0] == 0x8b && instruction.size == 7 { // option 1
      // Read the offset in the class's metadata that the implicit closure reads the address of the method from.
      try withUnsafePointer(to: instruction.bytes.advanced(by: 3), { pointer in
        try pointer.withMemoryRebound(to: Int32.self, capacity: 1, { pointer in
          let methodOffset = pointer.pointee
          
          // Access the method's address from its offset in the class's metadata
          let methodAddressAddress: UInt
          if methodOffset > 0 {
            methodAddressAddress = classMetadataAddress + UInt(methodOffset)
          } else {
            methodAddressAddress = classMetadataAddress - UInt(UInt32(abs(methodOffset)))
          }
          
          guard let address = UnsafeRawPointer(bitPattern: methodAddressAddress)?.load(as: UInt.self) else {
            throw MixinError.createPointerFailed
          }
          
          methodAddress = address
        })
      })
    } else if instruction.isIn(group: .call) { // option 2
      // Read the destination of the call (dodgily)
      let hexString = instruction.operandsString.dropFirst(2)
      guard let address = UInt(hexString, radix: 16) else {
        print(instruction.description)
        throw MixinError.invalidCall
      }
      methodAddress = address
    }
    
    return methodAddress
  }
  
  /// Returns the address of the specified static method.
  public static func getStaticMethodAddress<T>(of staticMethod: T) throws -> UInt {
    let nestedImplicitClosureAddress = implicitClosure(of: staticMethod)
    let methodAddress = try getStructMethodAddress(fromNestedImplicitClosureAt: nestedImplicitClosureAddress)
    return methodAddress
  }
  
  /// Replaces a static method with another static method. Static methods are the same on both structs and classes.
  public static func replaceStaticMethod<T>(_ method: T, with replacement: T) throws {
    let methodAddress = try getStaticMethodAddress(of: method)
    let replacementAddress = try getStaticMethodAddress(of: replacement)
    overwrite_function(methodAddress, replacementAddress)
  }
  
  /// Backs up a static method to the specified destination method to allow the original method to still be called
  /// even once it is replaced.
  public static func backupStaticMethod<T>(_ method: T, to destinationMethod: T) throws {
    let methodAddress = try getStaticMethodAddress(of: method)
    let destinationAddress = try getStaticMethodAddress(of: destinationMethod)
    let duplicateAddress = try duplicateFunction(at: methodAddress)
    overwrite_function(destinationAddress, duplicateAddress)
  }
}
