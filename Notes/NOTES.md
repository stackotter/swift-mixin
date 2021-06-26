# Some notes for myself on how functions and memory work in Swift

## Function as argument

In the following, `function` is a pointer straight to the function that can be called like in c..

```swift
func runFunction(_ function: () -> ()) {
  function()
}
```

The following runs a () -> () function passed as a generic. This can likely be modified to find the address of the function passed in.

```swift
func runGenericThatIsFunction<T>(_ function: T) {
  if let function = function as? () -> () {
    function()
  }
}
```

Below is the assembly for the function above. We should be able to figure out how the function is passed in by analysing what the function does.
The `call rcx` instruction corresponds to `function()`. We just need to figure out where `rcx` is from

```
MixinTest`runGenericThatIsFunction<T>(_:):
    0x100003440 <+0>:   push   rbp
    0x100003441 <+1>:   mov    rbp, rsp
    0x100003444 <+4>:   push   r13
    0x100003446 <+6>:   sub    rsp, 0xb8
    0x10000344d <+13>:  mov    qword ptr [rbp - 0x18], 0x0
    0x100003455 <+21>:  xorps  xmm0, xmm0
    0x100003458 <+24>:  movaps xmmword ptr [rbp - 0x40], xmm0
    0x10000345c <+28>:  mov    qword ptr [rbp - 0x10], rsi
    0x100003460 <+32>:  mov    rax, qword ptr [rsi - 0x8]
    0x100003464 <+36>:  mov    rcx, qword ptr [rax + 0x40]
    0x100003468 <+40>:  add    rcx, 0xf
    0x10000346c <+44>:  and    rcx, -0x10
    0x100003470 <+48>:  mov    rdx, rsp
    0x100003473 <+51>:  sub    rdx, rcx
    0x100003476 <+54>:  mov    rsp, rdx
    0x100003479 <+57>:  mov    qword ptr [rbp - 0x18], rdi
    0x10000347d <+61>:  mov    qword ptr [rbp - 0x48], rdi
    0x100003481 <+65>:  mov    rdi, rdx
    0x100003484 <+68>:  mov    rcx, qword ptr [rbp - 0x48]
    0x100003488 <+72>:  mov    qword ptr [rbp - 0x50], rsi
    0x10000348c <+76>:  mov    rsi, rcx
    0x10000348f <+79>:  mov    r8, qword ptr [rbp - 0x50]
    0x100003493 <+83>:  mov    qword ptr [rbp - 0x58], rdx
    0x100003497 <+87>:  mov    rdx, r8
    0x10000349a <+90>:  call   qword ptr [rax + 0x10]
    0x10000349d <+93>:  lea    rcx, [rbp - 0x28]
    0x1000034a1 <+97>:  lea    rdi, [rip + 0x5298]       ; demangling cache variable for type metadata for () -> ()
    0x1000034a8 <+104>: mov    qword ptr [rbp - 0x60], rax
    0x1000034ac <+108>: mov    qword ptr [rbp - 0x68], rcx
    0x1000034b0 <+112>: call   0x100003170               ; __swift_instantiateConcreteTypeFromMangledName at <compiler-generated>
    0x1000034b5 <+117>: mov    rdi, qword ptr [rbp - 0x68]
    0x1000034b9 <+121>: mov    rsi, qword ptr [rbp - 0x58]
    0x1000034bd <+125>: mov    rdx, qword ptr [rbp - 0x50]
    0x1000034c1 <+129>: mov    rcx, rax
    0x1000034c4 <+132>: mov    r8d, 0x6
    0x1000034ca <+138>: call   0x1000072e4               ; symbol stub for: swift_dynamicCast
    0x1000034cf <+143>: test   al, 0x1
    0x1000034d1 <+145>: jne    0x1000034d5               ; <+149> at main.swift
    0x1000034d3 <+147>: jmp    0x10000352b               ; <+235> at main.swift
    0x1000034d5 <+149>: lea    rax, [rip + 0x4f3c]
    0x1000034dc <+156>: add    rax, 0x10
    0x1000034e2 <+162>: mov    rcx, qword ptr [rbp - 0x28]
    0x1000034e6 <+166>: mov    rdx, qword ptr [rbp - 0x20]
    0x1000034ea <+170>: mov    rdi, rax
    0x1000034ed <+173>: mov    esi, 0x20
    0x1000034f2 <+178>: mov    eax, 0x7
    0x1000034f7 <+183>: mov    qword ptr [rbp - 0x70], rdx
    0x1000034fb <+187>: mov    rdx, rax
    0x1000034fe <+190>: mov    qword ptr [rbp - 0x78], rcx
    0x100003502 <+194>: call   0x1000072cc               ; symbol stub for: swift_allocObject
    0x100003507 <+199>: mov    rcx, qword ptr [rbp - 0x78]
    0x10000350b <+203>: mov    qword ptr [rax + 0x10], rcx
    0x10000350f <+207>: mov    rcx, qword ptr [rbp - 0x70]
    0x100003513 <+211>: mov    qword ptr [rax + 0x18], rcx
    0x100003517 <+215>: lea    rcx, [rip + 0x302]        ; partial apply forwarder for reabstraction thunk helper from @escaping @callee_guaranteed () -> (@out ()) to @escaping @callee_guaranteed () -> () at <compiler-generated>
    0x10000351e <+222>: mov    qword ptr [rbp - 0x80], rcx
    0x100003522 <+226>: mov    qword ptr [rbp - 0x88], rax
    0x100003529 <+233>: jmp    0x10000353d               ; <+253> at main.swift
    0x10000352b <+235>: xor    eax, eax
    0x10000352d <+237>: mov    ecx, eax
    0x10000352f <+239>: mov    rdx, rcx
    0x100003532 <+242>: mov    qword ptr [rbp - 0x80], rdx
    0x100003536 <+246>: mov    qword ptr [rbp - 0x88], rcx
    0x10000353d <+253>: mov    rax, qword ptr [rbp - 0x88]
    0x100003544 <+260>: mov    rcx, qword ptr [rbp - 0x80]
    0x100003548 <+264>: cmp    rcx, 0x0
    0x10000354c <+268>: mov    qword ptr [rbp - 0x90], rax
    0x100003553 <+275>: mov    qword ptr [rbp - 0x98], rcx
    0x10000355a <+282>: je     0x10000357a               ; <+314> at main.swift:61:30
    0x10000355c <+284>: mov    rax, qword ptr [rbp - 0x98]
    0x100003563 <+291>: mov    rcx, qword ptr [rbp - 0x90]
    0x10000356a <+298>: mov    qword ptr [rbp - 0xa0], rax
    0x100003571 <+305>: mov    qword ptr [rbp - 0xa8], rcx
    0x100003578 <+312>: jmp    0x10000357c               ; <+316> at main.swift
    0x10000357a <+314>: jmp    0x1000035d7               ; <+407> at main.swift:64:1
    0x10000357c <+316>: mov    rax, qword ptr [rbp - 0xa8]
    0x100003583 <+323>: mov    rcx, qword ptr [rbp - 0xa0]
    0x10000358a <+330>: mov    qword ptr [rbp - 0x40], rcx
    0x10000358e <+334>: mov    qword ptr [rbp - 0x38], rax
->  0x100003592 <+338>: mov    rdi, rax
    0x100003595 <+341>: mov    qword ptr [rbp - 0xb0], rax
    0x10000359c <+348>: mov    qword ptr [rbp - 0xb8], rcx
    0x1000035a3 <+355>: call   0x10000730e               ; symbol stub for: swift_retain
    0x1000035a8 <+360>: mov    r13, qword ptr [rbp - 0xb0]
    0x1000035af <+367>: mov    rcx, qword ptr [rbp - 0xb8]
    0x1000035b6 <+374>: mov    qword ptr [rbp - 0xc0], rax
    0x1000035bd <+381>: call   rcx
    0x1000035bf <+383>: mov    rdi, qword ptr [rbp - 0xb0]
    0x1000035c6 <+390>: call   0x100007308               ; symbol stub for: swift_release
    0x1000035cb <+395>: mov    rdi, qword ptr [rbp - 0xb0]
    0x1000035d2 <+402>: call   0x100007308               ; symbol stub for: swift_release
    0x1000035d7 <+407>: lea    rsp, [rbp - 0x8]
    0x1000035db <+411>: pop    r13
    0x1000035dd <+413>: pop    rbp
    0x1000035de <+414>: ret    
    0x1000035df <+415>: nop 
```

At `call rcx`, `rcx` contains a pointer to a weird reabstraction function. The disassembly of which is below;

```
MixinTest`partial apply for thunk for @escaping @callee_guaranteed () -> (@out ()):
    0x100003820 <+0>:  push   rbp
    0x100003821 <+1>:  mov    rbp, rsp
    0x100003824 <+4>:  mov    rdi, qword ptr [r13 + 0x10]
    0x100003828 <+8>:  mov    rsi, qword ptr [r13 + 0x18]
    0x10000382c <+12>: pop    rbp
    0x10000382d <+13>: jmp    0x1000037d0               ; reabstraction thunk helper from @escaping @callee_guaranteed () -> (@out ()) to @escaping @callee_guaranteed () -> () at <compiler-generated>
    0x100003832 <+18>: nop    word ptr cs:[rax + rax]
    0x10000383c <+28>: nop    dword ptr [rax]
```

The important line is the `jmp` instruction which jumps into the following function;

```
MixinTest`thunk for @escaping @callee_guaranteed () -> (@out ()):
    0x1000037d0 <+0>:  push   rbp
    0x1000037d1 <+1>:  mov    rbp, rsp
    0x1000037d4 <+4>:  push   r13
    0x1000037d6 <+6>:  push   rax
    0x1000037d7 <+7>:  mov    r13, rsi
    0x1000037da <+10>: call   rdi
    0x1000037dc <+12>: add    rsp, 0x8
    0x1000037e0 <+16>: pop    r13
    0x1000037e2 <+18>: pop    rbp
    0x1000037e3 <+19>: ret    
    0x1000037e4 <+20>: nop    word ptr cs:[rax + rax]
    0x1000037ee <+30>: nop  
```

With some initial dynamic analysis we can see it calls another function (dynamic this time).

```
MixinTest`thunk for @escaping @callee_guaranteed () -> ()partial apply:
->  0x100003420 <+0>:  push   rbp
    0x100003421 <+1>:  mov    rbp, rsp
    0x100003424 <+4>:  mov    rdi, qword ptr [r13 + 0x10]
    0x100003428 <+8>:  mov    rsi, qword ptr [r13 + 0x18]
    0x10000342c <+12>: call   0x100003100               ; reabstraction thunk helper from @escaping @callee_guaranteed () -> () to @escaping @callee_guaranteed () -> (@out ()) at <compiler-generated>
    0x100003431 <+17>: pop    rbp
    0x100003432 <+18>: ret    
    0x100003433 <+19>: nop    word ptr cs:[rax + rax]
    0x10000343d <+29>: nop    dword ptr [rax]
```

The function called by the above code (disassembly below) calls whatever is in `rdi` which happens to finally be `function2`! Now we just need to figure out where that came from.

```
MixinTest`thunk for @escaping @callee_guaranteed () -> ():
->  0x100003100 <+0>:  push   rbp
    0x100003101 <+1>:  mov    rbp, rsp
    0x100003104 <+4>:  push   r13
    0x100003106 <+6>:  push   rax
    0x100003107 <+7>:  mov    r13, rsi
    0x10000310a <+10>: call   rdi
    0x10000310c <+12>: add    rsp, 0x8
    0x100003110 <+16>: pop    r13
    0x100003112 <+18>: pop    rbp
    0x100003113 <+19>: ret    
    0x100003114 <+20>: nop    word ptr cs:[rax + rax]
    0x10000311e <+30>: nop  
```

Between 0x100003502 and 0x1000035bd in runGenericThatIsFunction(_:) the code is filling out a struct with the following layout;

{
  \+ 0x10: pointer to `MixinTest`partial apply for thunk for @escaping @callee_guaranteed () -> (@out ())`
  \+ 0x18: pointer to memory {
      \+ 0x10: `function2`
    }
}

At an offset of 0x10 there is some sort of odd function that doesn't seem to do anything important (at least for a `() -> ()` type function). At an offset of 0x18 there is a pointer to another piece of memory. This other piece of memory contains a pointer to `function2` at an offset of 0x10. Somehow we need to find out where this comes from.

It seems as if `rdi` is a 'value witness table'. 

I have found where in the argument the function pointer is. The function `getFunctionAddress<T>(_:)` gets passed a pointer to a `GenericFunction` (these are just structures for what I know so far). That struct contains a pointer to a thunk and what I'm assuming is some kind of metadata struct. The third member of the metadata struct (assuming each takes up 64 bits) is a pointer to the function passed in.

```swift
struct GenericFunction {
  var thunk: UInt64
  var metadata: UnsafePointer<FunctionMetadata>
}

struct FunctionMetadata {
  var arg1: UInt64
  var arg2: UInt64
  var functionPointer: UInt64
}

func getFunctionAddress<T>(_ function: T) -> UInt64 {
  var functionAddress: UInt64 = 0
  withUnsafePointer(to: function, { pointer in
    pointer.withMemoryRebound(to: GenericFunction.self, capacity: 1, { pointer in
      functionAddress = pointer.pointee.metadata.pointee.functionPointer
    })
  })
  return functionAddress
}
```

mprotect'ing function memory pages to add write gives permission denied. MachO maxprot for __text segment was changed to 0x5 at some point, patch it to be 0x7 (with a command and also on the fly).

All normal functions work now. Methods of structs and classes do not. Consider the following struct;

```swift
struct TwoNumbers {
  var a: Int
  var b: Int
  
  init(a: Int, b: Int) {
    self.a = a
    self.b = b
  }
  
  func sum() -> Int {
    return a + b
  }
  
  func product() -> Int {
    return a * b
  }
}
```

Passing `TwoNumbers.sum` to a function taking a generic type passes some multiply nested tuple kind of deal. Then the call to `TwoNumber.sum` is actually hardcoded into a thunk or reabstraction handler or something. Could possibly get the address of the thunk with the call hardcoded in and then iterate through the instructions and find the address passed to call.

The signature of `TwoNumber.sum` is `(TwoNumbers) -> () -> Int`. Replacing an explicit function of that type works fine, but a new thunk is generated each time a struct method is passed to a function.



## First `call rax`

rdi is result of TwoNumbers.init

context+0x10 is next thunk
context+0x18 is context for next thunk

0x10000ad70

rdi is a TwoNumbers
rsi is context+0x10 (pointer to the thunk after next)
rdx is context+0x18 (context for thunk after next)

0x10000a830

rdi is a
rsi is b
rdx is next thunk

0x10000acd0

## Second `call rax`

0x10000aeb0

rdi is context + 0x10 (pointer to the thunk after next)
rsi is context + 0x18 (context for thunk after next)

0x1000075e0

rdi is pointer to rdi
rax is pointer to rbp - 0x28

0x10000af40

rdi is context + 0x10 (pointer to the thunk after next)
rsi is context + 0x18 (context for the thunk after next containing TwoNumbers at +0x10)

0x10000aef0

rdi is context + 0x10 (a)
rsi is context + 0x18 (b)



Getting address to TwoNumbers.sum from context passed to second `call rax`;

1. get thunk at [r13+0x18]+0x10
2. find jmp instruction and get address it jumps to
3. parse the function it jumps into and find the call instruction, the address passed to that is TwoNumbers.sum

Need to find the address of 0x10000a790 because it returns the address of the function at [r13+0x18]+0x10 as passed to the second `call rax`. Can then maybe find the address of the function and run it from c to get the address of the thunk and then continue from step 2 above. The address can be found passed to the function at [rdi+0x08]+0x10
