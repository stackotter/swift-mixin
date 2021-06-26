# Struct

./AnalysedBinaries/MixinTestMethodCalls

## Calling sum normally

- 0x10000ad50

- 0x10000af20
  - 0x10000adc0
    - 0x100009250*: the actual function

## Calling sum from a casted generic - 1

- 0x10000ae90*
  - 0x10000adf0*
    - 0x10000a7e0
      - 0x10000a730*
        - 0x10000a690

- 0x10000aee0*
  - 0x1000075d0*
    - 0x10000afb0*
      - 0x10000a800*
        - 0x10000aff0 <- we have the address of this
          - 0x10000a700
            - 0x100009250*: the actual function

## Calling sum from a casted generic - 2

- 0x10000ae90*
  - 0x10000adf0*
    - 0x10000ad00
      - 0x10000a730*
        - 0x10000ac60 -> returns 0x10000af60

- 0x10000aee0*
  - 0x1000075d0*
    - 0x10000afb0*
      - 0x10000a800*
        - 0x10000af60 <- we have the address of this
          - 0x10000ad20
            - 0x100009250*: the actual function

* means a shared closure/thunk/function call/jmp

We have the address of the second last thunk before the actual function. The next two thunks both do hardcoded jumps and calls so we need to extract those address. 

## Way to extract actual function address

```swift
func getMethodAddress<T>(_ method: T) {
  // stuff
}
```

When this function is called as follows `TwoNumbers.sum` we get some metadata about some partial application closure in rdi. There is an address at rdi + 0x08. And at that address + 0x10 is 0x10000ac60 (see 'Calling sum from a casted generic - 2' for the functions called). Calling this function gives us the address to the thunk at 0x10000af60. The plan now is;

1. Iteratively search through the thunk at 0x10000af60 and look for a `pop rbp` instruction followed by a `jmp`.
2. Make a parser that can extract the address of the next thunk from the `jmp` instruction.
3. Iteratively search through the next thunk (0x10000ad20) for a `ret` instruction, then skip backwards 10 bytes to get to the `call`.
4. Make a parser that can extract the address of the actual function from the `call` instruction.


# Classes

## First time

- 0x10000cc70
  - 0x10000cba0
    - 0x10000c6d0
      - 0x10000c630 
        - 0x10000c5c0
- 0x10000cce0
  - 0x10000cc90
    - 0x10000cd40
      - 0x10000b790
        - 0x10000cd60
          - 0x10000c600
            - 0x100008d60

## Another time

- 0x10000cca0
  - 0x10000cbd0
    - 0x10000c7c0
      - 0x10000c720
        - 0x10000c6b0 -> returns 0x10000cd80
- 0x10000cd10
  - 0x10000ccc0
    - 0x10000cd60
      - 0x10000b9b0
        - 0x10000cd80
          - 0x10000c6f0
            - 0x100008f80 <- the actual function `ThreeNumbers.sum`

0x0000000100c523c0

```
(lldb) d -a  0x100008f80
MixinTest`ThreeNumbers.sum():
    0x100008f80 <+0>:   push   rbp
    0x100008f81 <+1>:   mov    rbp, rsp
    0x100008f84 <+4>:   push   r13
    0x100008f86 <+6>:   sub    rsp, 0x28
    0x100008f8a <+10>:  xor    esi, esi
    0x100008f8c <+12>:  lea    rax, [rbp - 0x10]
    0x100008f90 <+16>:  mov    rdi, rax
    0x100008f93 <+19>:  mov    edx, 0x8
    0x100008f98 <+24>:  mov    qword ptr [rbp - 0x18], r13
    0x100008f9c <+28>:  call   0x10000e6fa               ; symbol stub for: memset
    0x100008fa1 <+33>:  mov    rax, qword ptr [rbp - 0x18]
    0x100008fa5 <+37>:  mov    qword ptr [rbp - 0x10], rax
    0x100008fa9 <+41>:  mov    rcx, qword ptr [rax]
    0x100008fac <+44>:  mov    r13, rax
    0x100008faf <+47>:  call   qword ptr [rcx + 0x68]
    0x100008fb2 <+50>:  mov    rcx, qword ptr [rbp - 0x18]
    0x100008fb6 <+54>:  mov    rdx, qword ptr [rcx]
    0x100008fb9 <+57>:  mov    r13, rcx
    0x100008fbc <+60>:  mov    qword ptr [rbp - 0x20], rax
    0x100008fc0 <+64>:  call   qword ptr [rdx + 0x80]
    0x100008fc6 <+70>:  mov    rcx, qword ptr [rbp - 0x20]
    0x100008fca <+74>:  add    rcx, rax
    0x100008fcd <+77>:  seto   r8b
    0x100008fd1 <+81>:  test   r8b, 0x1
    0x100008fd5 <+85>:  mov    qword ptr [rbp - 0x28], rcx
    0x100008fd9 <+89>:  jne    0x10000900a               ; <+138> [inlined] Swift runtime failure: arithmetic overflow at TestFunctions.swift:71
    0x100008fdb <+91>:  mov    rax, qword ptr [rbp - 0x18]
    0x100008fdf <+95>:  mov    rcx, qword ptr [rax]
    0x100008fe2 <+98>:  mov    r13, rax
    0x100008fe5 <+101>: call   qword ptr [rcx + 0x98]
    0x100008feb <+107>: mov    rcx, qword ptr [rbp - 0x28]
    0x100008fef <+111>: add    rcx, rax
    0x100008ff2 <+114>: seto   dl
    0x100008ff5 <+117>: test   dl, 0x1
    0x100008ff8 <+120>: mov    qword ptr [rbp - 0x30], rcx
    0x100008ffc <+124>: jne    0x10000900c               ; <+140> [inlined] Swift runtime failure: arithmetic overflow at TestFunctions.swift:71
    0x100008ffe <+126>: mov    rax, qword ptr [rbp - 0x30]
    0x100009002 <+130>: add    rsp, 0x28
    0x100009006 <+134>: pop    r13
    0x100009008 <+136>: pop    rbp
    0x100009009 <+137>: ret    
    0x10000900a <+138>: ud2    
    0x10000900c <+140>: ud2    
    
(lldb) d -a 0x10000c6f0
MixinTest`implicit closure #2 in implicit closure #1 in main():
    0x10000c6f0 <+0>:  push   rbp
    0x10000c6f1 <+1>:  mov    rbp, rsp
    0x10000c6f4 <+4>:  push   r13
    0x10000c6f6 <+6>:  push   rax
    0x10000c6f7 <+7>:  mov    qword ptr [rbp - 0x10], 0x0
    0x10000c6ff <+15>: mov    qword ptr [rbp - 0x10], rdi
    0x10000c703 <+19>: mov    rax, qword ptr [rdi]
    0x10000c706 <+22>: mov    rax, qword ptr [rax + 0xb8]
    0x10000c70d <+29>: mov    r13, rdi
    0x10000c710 <+32>: call   rax
    0x10000c712 <+34>: add    rsp, 0x8
    0x10000c716 <+38>: pop    r13
    0x10000c718 <+40>: pop    rbp
    0x10000c719 <+41>: ret    
    
(lldb) d -a 0x10000cd80
MixinTest`partial apply for implicit closure #2 in implicit closure #1 in main():
    0x10000cd80 <+0>: push   rbp
    0x10000cd81 <+1>: mov    rbp, rsp
    0x10000cd84 <+4>: mov    rdi, r13
    0x10000cd87 <+7>: pop    rbp
    0x10000cd88 <+8>: jmp    0x10000c6f0               ; implicit closure #2 () -> Swift.Int in implicit closure #1 (MixinTest.ThreeNumbers) -> () -> Swift.Int in MixinTest.main() -> () at main.swift

(lldb) d -a 0x10000b9b0
MixinTest`thunk for @escaping @callee_guaranteed () -> (@unowned Int):
    0x10000b9b0 <+0>:  push   rbp
    0x10000b9b1 <+1>:  mov    rbp, rsp
    0x10000b9b4 <+4>:  push   r13
    0x10000b9b6 <+6>:  push   rax
    0x10000b9b7 <+7>:  mov    r13, rsi
    0x10000b9ba <+10>: mov    qword ptr [rbp - 0x10], rax
    0x10000b9be <+14>: call   rdi
    0x10000b9c0 <+16>: mov    rcx, qword ptr [rbp - 0x10]
    0x10000b9c4 <+20>: mov    qword ptr [rcx], rax
    0x10000b9c7 <+23>: add    rsp, 0x8
    0x10000b9cb <+27>: pop    r13
    0x10000b9cd <+29>: pop    rbp
    0x10000b9ce <+30>: ret    

(lldb) d -a 0x10000cd60
MixinTest`partial apply for thunk for @escaping @callee_guaranteed () -> (@unowned Int):
    0x10000cd60 <+0>:  push   rbp
    0x10000cd61 <+1>:  mov    rbp, rsp
    0x10000cd64 <+4>:  mov    rdi, qword ptr [r13 + 0x10]
    0x10000cd68 <+8>:  mov    rsi, qword ptr [r13 + 0x18]
    0x10000cd6c <+12>: call   0x10000b9b0               ; reabstraction thunk helper from @escaping @callee_guaranteed () -> (@unowned Swift.Int) to @escaping @callee_guaranteed () -> (@out Swift.Int) at <compiler-generated>
    0x10000cd71 <+17>: pop    rbp
    0x10000cd72 <+18>: ret    

(lldb) d -a 0x10000ccc0
MixinTest`thunk for @escaping @callee_guaranteed () -> (@out Int):
    0x10000ccc0 <+0>:  push   rbp
    0x10000ccc1 <+1>:  mov    rbp, rsp
    0x10000ccc4 <+4>:  push   r13
    0x10000ccc6 <+6>:  push   rax
    0x10000ccc7 <+7>:  lea    rax, [rbp - 0x10]
    0x10000cccb <+11>: mov    r13, rsi
    0x10000ccce <+14>: call   rdi
    0x10000ccd0 <+16>: mov    rax, qword ptr [rbp - 0x10]
    0x10000ccd4 <+20>: add    rsp, 0x8
    0x10000ccd8 <+24>: pop    r13
    0x10000ccda <+26>: pop    rbp
    0x10000ccdb <+27>: ret    

(lldb) d -a 0x10000cd10
MixinTest`partial apply for thunk for @escaping @callee_guaranteed () -> (@out Int):
    0x10000cd10 <+0>:  push   rbp
    0x10000cd11 <+1>:  mov    rbp, rsp
    0x10000cd14 <+4>:  mov    rdi, qword ptr [r13 + 0x10]
    0x10000cd18 <+8>:  mov    rsi, qword ptr [r13 + 0x18]
    0x10000cd1c <+12>: pop    rbp
    0x10000cd1d <+13>: jmp    0x10000ccc0               ; reabstraction thunk helper from @escaping @callee_guaranteed () -> (@out Swift.Int) to @escaping @callee_guaranteed () -> (@unowned Swift.Int) at <compiler-generated>
(lldb)
```

```
(lldb) d -a 0x10000c6b0
MixinTest`implicit closure #1 in main():
    0x10000c6b0 <+0>:  push   rbp
    0x10000c6b1 <+1>:  mov    rbp, rsp
    0x10000c6b4 <+4>:  sub    rsp, 0x20
    0x10000c6b8 <+8>:  mov    qword ptr [rbp - 0x8], 0x0
    0x10000c6c0 <+16>: mov    qword ptr [rbp - 0x8], rdi
    0x10000c6c4 <+20>: mov    qword ptr [rbp - 0x10], rdi
    0x10000c6c8 <+24>: call   0x10000e78a               ; symbol stub for: swift_retain
    0x10000c6cd <+29>: lea    rcx, [rip + 0x6ac]        ; partial apply forwarder for implicit closure #2 () -> Swift.Int in implicit closure #1 (MixinTest.ThreeNumbers) -> () -> Swift.Int in MixinTest.main() -> () at <compiler-generated>
    0x10000c6d4 <+36>: mov    qword ptr [rbp - 0x18], rax
    0x10000c6d8 <+40>: mov    rax, rcx
    0x10000c6db <+43>: mov    rdx, qword ptr [rbp - 0x10]
    0x10000c6df <+47>: add    rsp, 0x20
    0x10000c6e3 <+51>: pop    rbp
    0x10000c6e4 <+52>: ret    

(lldb) d -a 0x10000c720
MixinTest`thunk for @escaping @callee_guaranteed (@guaranteed ThreeNumbers) -> (@owned @escaping @callee_guaranteed () -> (@unowned Int)):
    0x10000c720 <+0>:  push   rbp
    0x10000c721 <+1>:  mov    rbp, rsp
    0x10000c724 <+4>:  push   r13
    0x10000c726 <+6>:  sub    rsp, 0x18
    0x10000c72a <+10>: mov    rdi, qword ptr [rdi]
    0x10000c72d <+13>: mov    r13, rdx
    0x10000c730 <+16>: mov    qword ptr [rbp - 0x10], rax
    0x10000c734 <+20>: call   rsi
    0x10000c736 <+22>: lea    rdi, [rip + 0x408b]       ; type metadata for MixinTest.Numbers + 672
    0x10000c73d <+29>: mov    esi, 0x20
    0x10000c742 <+34>: mov    ecx, 0x7
    0x10000c747 <+39>: mov    qword ptr [rbp - 0x18], rdx
    0x10000c74b <+43>: mov    rdx, rcx
    0x10000c74e <+46>: mov    qword ptr [rbp - 0x20], rax
    0x10000c752 <+50>: call   0x10000e724               ; symbol stub for: swift_allocObject
    0x10000c757 <+55>: mov    rcx, qword ptr [rbp - 0x20]
    0x10000c75b <+59>: mov    qword ptr [rax + 0x10], rcx
    0x10000c75f <+63>: mov    rdx, qword ptr [rbp - 0x18]
    0x10000c763 <+67>: mov    qword ptr [rax + 0x18], rdx
    0x10000c767 <+71>: lea    rsi, [rip + 0x5f2]        ; partial apply forwarder for reabstraction thunk helper from @escaping @callee_guaranteed () -> (@unowned Swift.Int) to @escaping @callee_guaranteed () -> (@out Swift.Int) at <compiler-generated>
    0x10000c76e <+78>: mov    rdi, qword ptr [rbp - 0x10]
    0x10000c772 <+82>: mov    qword ptr [rdi], rsi
    0x10000c775 <+85>: mov    qword ptr [rdi + 0x8], rax
    0x10000c779 <+89>: add    rsp, 0x18
    0x10000c77d <+93>: pop    r13
    0x10000c77f <+95>: pop    rbp
    0x10000c780 <+96>: ret    

(lldb) d -a 0x10000c7c0
MixinTest`partial apply for thunk for @escaping @callee_guaranteed (@guaranteed ThreeNumbers) -> (@owned @escaping @callee_guaranteed () -> (@unowned Int)):
    0x10000c7c0 <+0>:  push   rbp
    0x10000c7c1 <+1>:  mov    rbp, rsp
    0x10000c7c4 <+4>:  mov    rsi, qword ptr [r13 + 0x10]
    0x10000c7c8 <+8>:  mov    rdx, qword ptr [r13 + 0x18]
    0x10000c7cc <+12>: call   0x10000c720               ; reabstraction thunk helper from @escaping @callee_guaranteed (@guaranteed MixinTest.ThreeNumbers) -> (@owned @escaping @callee_guaranteed () -> (@unowned Swift.Int)) to @escaping @callee_guaranteed (@in_guaranteed MixinTest.ThreeNumbers) -> (@out @escaping @callee_guaranteed @substituted <A> () -> (@out A) for <Swift.Int>) at <compiler-generated>
    0x10000c7d1 <+17>: pop    rbp
    0x10000c7d2 <+18>: ret    

(lldb) d -a 0x10000cbd0
MixinTest`thunk for @escaping @callee_guaranteed (@in_guaranteed ThreeNumbers) -> (@out @escaping @callee_guaranteed @substituted <A> () -> (@out A) for <Int>):
    0x10000cbd0 <+0>:   push   rbp
    0x10000cbd1 <+1>:   mov    rbp, rsp
    0x10000cbd4 <+4>:   push   r13
    0x10000cbd6 <+6>:   sub    rsp, 0x58
    0x10000cbda <+10>:  mov    qword ptr [rbp - 0x28], rdi
    0x10000cbde <+14>:  mov    qword ptr [rbp - 0x30], rdx
    0x10000cbe2 <+18>:  mov    qword ptr [rbp - 0x38], rsi
    0x10000cbe6 <+22>:  call   0x10000e78a               ; symbol stub for: swift_retain
    0x10000cbeb <+27>:  mov    rcx, qword ptr [rbp - 0x28]
    0x10000cbef <+31>:  mov    qword ptr [rbp - 0x10], rcx
    0x10000cbf3 <+35>:  lea    rdx, [rbp - 0x20]
    0x10000cbf7 <+39>:  lea    rdi, [rbp - 0x10]
    0x10000cbfb <+43>:  mov    qword ptr [rbp - 0x40], rax
    0x10000cbff <+47>:  mov    rax, rdx
    0x10000cc02 <+50>:  mov    r13, qword ptr [rbp - 0x30]
    0x10000cc06 <+54>:  mov    rdx, qword ptr [rbp - 0x38]
    0x10000cc0a <+58>:  call   rdx
    0x10000cc0c <+60>:  mov    rax, qword ptr [rbp - 0x20]
    0x10000cc10 <+64>:  mov    rcx, qword ptr [rbp - 0x18]
    0x10000cc14 <+68>:  lea    rdi, [rip + 0x3b85]       ; type metadata for MixinTest.Numbers + 632
    0x10000cc1b <+75>:  mov    esi, 0x20
    0x10000cc20 <+80>:  mov    edx, 0x7
    0x10000cc25 <+85>:  mov    qword ptr [rbp - 0x48], rax
    0x10000cc29 <+89>:  mov    qword ptr [rbp - 0x50], rcx
    0x10000cc2d <+93>:  call   0x10000e724               ; symbol stub for: swift_allocObject
    0x10000cc32 <+98>:  mov    rcx, qword ptr [rbp - 0x48]
    0x10000cc36 <+102>: mov    qword ptr [rax + 0x10], rcx
    0x10000cc3a <+106>: mov    rcx, qword ptr [rbp - 0x50]
    0x10000cc3e <+110>: mov    qword ptr [rax + 0x18], rcx
    0x10000cc42 <+114>: mov    rdi, qword ptr [rbp - 0x10]
    0x10000cc46 <+118>: mov    qword ptr [rbp - 0x58], rax
    0x10000cc4a <+122>: call   0x10000e784               ; symbol stub for: swift_release
    0x10000cc4f <+127>: lea    rax, [rip + 0xba]         ; partial apply forwarder for reabstraction thunk helper from @escaping @callee_guaranteed () -> (@out Swift.Int) to @escaping @callee_guaranteed () -> (@unowned Swift.Int) at <compiler-generated>
    0x10000cc56 <+134>: mov    rdx, qword ptr [rbp - 0x58]
    0x10000cc5a <+138>: add    rsp, 0x58
    0x10000cc5e <+142>: pop    r13
    0x10000cc60 <+144>: pop    rbp
    0x10000cc61 <+145>: ret    

(lldb) d -a 0x10000cca0
MixinTest`partial apply for thunk for @escaping @callee_guaranteed (@in_guaranteed ThreeNumbers) -> (@out @escaping @callee_guaranteed @substituted <A> () -> (@out A) for <Int>):
    0x10000cca0 <+0>:  push   rbp
    0x10000cca1 <+1>:  mov    rbp, rsp
    0x10000cca4 <+4>:  mov    rsi, qword ptr [r13 + 0x10]
    0x10000cca8 <+8>:  mov    rdx, qword ptr [r13 + 0x18]
    0x10000ccac <+12>: pop    rbp
    0x10000ccad <+13>: jmp    0x10000cbd0               ; reabstraction thunk helper from @escaping @callee_guaranteed (@in_guaranteed MixinTest.ThreeNumbers) -> (@out @escaping @callee_guaranteed @substituted <A> () -> (@out A) for <Swift.Int>) to @escaping @callee_guaranteed (@guaranteed MixinTest.ThreeNumbers) -> (@owned @escaping @callee_guaranteed () -> (@unowned Swift.Int)) at <compiler-generated>
(lldb) 
```

```
MixinTest`runSum<T>(_:):
    0x10000c7e0 <+0>:   push   rbp
    0x10000c7e1 <+1>:   mov    rbp, rsp
    0x10000c7e4 <+4>:   push   r13
    0x10000c7e6 <+6>:   sub    rsp, 0x158
    0x10000c7ed <+13>:  mov    qword ptr [rbp - 0x18], 0x0
    0x10000c7f5 <+21>:  xorps  xmm0, xmm0
    0x10000c7f8 <+24>:  movaps xmmword ptr [rbp - 0x40], xmm0
    0x10000c7fc <+28>:  mov    qword ptr [rbp - 0x48], 0x0
    0x10000c804 <+36>:  mov    qword ptr [rbp - 0x50], 0x0
    0x10000c80c <+44>:  movaps xmmword ptr [rbp - 0x60], xmm0
    0x10000c810 <+48>:  mov    qword ptr [rbp - 0x10], rsi
    0x10000c814 <+52>:  mov    rax, qword ptr [rsi - 0x8]
    0x10000c818 <+56>:  mov    rcx, qword ptr [rax + 0x40]
    0x10000c81c <+60>:  add    rcx, 0xf
    0x10000c820 <+64>:  and    rcx, -0x10
    0x10000c824 <+68>:  mov    rdx, rsp
    0x10000c827 <+71>:  sub    rdx, rcx
    0x10000c82a <+74>:  mov    rsp, rdx
    0x10000c82d <+77>:  mov    qword ptr [rbp - 0x18], rdi
    0x10000c831 <+81>:  mov    qword ptr [rbp - 0x70], rdi
    0x10000c835 <+85>:  mov    rdi, rdx
    0x10000c838 <+88>:  mov    rcx, qword ptr [rbp - 0x70]
    0x10000c83c <+92>:  mov    qword ptr [rbp - 0x78], rsi
    0x10000c840 <+96>:  mov    rsi, rcx
    0x10000c843 <+99>:  mov    r8, qword ptr [rbp - 0x78]
    0x10000c847 <+103>: mov    qword ptr [rbp - 0x80], rdx
    0x10000c84b <+107>: mov    rdx, r8
    0x10000c84e <+110>: call   qword ptr [rax + 0x10]
    0x10000c851 <+113>: lea    rcx, [rbp - 0x28]
    0x10000c855 <+117>: lea    rdi, [rip + 0x7cfc]       ; demangling cache variable for type metadata for (MixinTest.ThreeNumbers) -> () -> Swift.Int
    0x10000c85c <+124>: mov    qword ptr [rbp - 0x88], rax
    0x10000c863 <+131>: mov    qword ptr [rbp - 0x90], rcx
    0x10000c86a <+138>: call   0x100005ea0               ; __swift_instantiateConcreteTypeFromMangledName at <compiler-generated>
    0x10000c86f <+143>: mov    rdi, qword ptr [rbp - 0x90]
    0x10000c876 <+150>: mov    rsi, qword ptr [rbp - 0x80]
    0x10000c87a <+154>: mov    rdx, qword ptr [rbp - 0x78]
    0x10000c87e <+158>: mov    rcx, rax
    0x10000c881 <+161>: mov    r8d, 0x6
    0x10000c887 <+167>: call   0x10000e748               ; symbol stub for: swift_dynamicCast
    0x10000c88c <+172>: test   al, 0x1
    0x10000c88e <+174>: jne    0x10000c892               ; <+178> at main.swift
    0x10000c890 <+176>: jmp    0x10000c8f7               ; <+279> at main.swift
    0x10000c892 <+178>: lea    rax, [rip + 0x3ecf]       ; type metadata for MixinTest.Numbers + 576
    0x10000c899 <+185>: add    rax, 0x10
    0x10000c89f <+191>: mov    rcx, qword ptr [rbp - 0x28]
    0x10000c8a3 <+195>: mov    rdx, qword ptr [rbp - 0x20]
    0x10000c8a7 <+199>: mov    rdi, rax
    0x10000c8aa <+202>: mov    esi, 0x20
    0x10000c8af <+207>: mov    eax, 0x7
    0x10000c8b4 <+212>: mov    qword ptr [rbp - 0x98], rdx
    0x10000c8bb <+219>: mov    rdx, rax
    0x10000c8be <+222>: mov    qword ptr [rbp - 0xa0], rcx
    0x10000c8c5 <+229>: call   0x10000e724               ; symbol stub for: swift_allocObject
    0x10000c8ca <+234>: mov    rcx, qword ptr [rbp - 0xa0]
    0x10000c8d1 <+241>: mov    qword ptr [rax + 0x10], rcx
    0x10000c8d5 <+245>: mov    rcx, qword ptr [rbp - 0x98]
    0x10000c8dc <+252>: mov    qword ptr [rax + 0x18], rcx
    0x10000c8e0 <+256>: lea    rcx, [rip + 0x3b9]        ; partial apply forwarder for reabstraction thunk helper from @escaping @callee_guaranteed (@in_guaranteed MixinTest.ThreeNumbers) -> (@out @escaping @callee_guaranteed @substituted <A> () -> (@out A) for <Swift.Int>) to @escaping @callee_guaranteed (@guaranteed MixinTest.ThreeNumbers) -> (@owned @escaping @callee_guaranteed () -> (@unowned Swift.Int)) at <compiler-generated>
    0x10000c8e7 <+263>: mov    qword ptr [rbp - 0xa8], rcx
    0x10000c8ee <+270>: mov    qword ptr [rbp - 0xb0], rax
    0x10000c8f5 <+277>: jmp    0x10000c90c               ; <+300> at main.swift
    0x10000c8f7 <+279>: xor    eax, eax
    0x10000c8f9 <+281>: mov    ecx, eax
    0x10000c8fb <+283>: mov    rdx, rcx
    0x10000c8fe <+286>: mov    qword ptr [rbp - 0xa8], rdx
    0x10000c905 <+293>: mov    qword ptr [rbp - 0xb0], rcx
    0x10000c90c <+300>: mov    rax, qword ptr [rbp - 0xb0]
    0x10000c913 <+307>: mov    rcx, qword ptr [rbp - 0xa8]
    0x10000c91a <+314>: cmp    rcx, 0x0
    0x10000c91e <+318>: mov    qword ptr [rbp - 0xb8], rax
    0x10000c925 <+325>: mov    qword ptr [rbp - 0xc0], rcx
    0x10000c92c <+332>: je     0x10000c94c               ; <+364> at main.swift:112:30
    0x10000c92e <+334>: mov    rax, qword ptr [rbp - 0xc0]
    0x10000c935 <+341>: mov    rcx, qword ptr [rbp - 0xb8]
    0x10000c93c <+348>: mov    qword ptr [rbp - 0xc8], rax
    0x10000c943 <+355>: mov    qword ptr [rbp - 0xd0], rcx
    0x10000c94a <+362>: jmp    0x10000c951               ; <+369> at main.swift
    0x10000c94c <+364>: jmp    0x10000cbbf               ; <+991> at main.swift:119:1
    0x10000c951 <+369>: mov    rax, qword ptr [rbp - 0xd0]
    0x10000c958 <+376>: mov    rcx, qword ptr [rbp - 0xc8]
    0x10000c95f <+383>: xor    edx, edx
    0x10000c961 <+385>: mov    edi, edx
    0x10000c963 <+387>: mov    qword ptr [rbp - 0x40], rcx
    0x10000c967 <+391>: mov    qword ptr [rbp - 0x38], rax
    0x10000c96b <+395>: mov    qword ptr [rbp - 0xd8], rax
    0x10000c972 <+402>: mov    qword ptr [rbp - 0xe0], rcx
    0x10000c979 <+409>: call   0x100009520               ; type metadata accessor for MixinTest.ThreeNumbers at <compiler-generated>
    0x10000c97e <+414>: mov    edi, 0x1
    0x10000c983 <+419>: mov    esi, 0x2
    0x10000c988 <+424>: mov    ecx, 0x4
    0x10000c98d <+429>: mov    qword ptr [rbp - 0xe8], rdx
    0x10000c994 <+436>: mov    rdx, rcx
    0x10000c997 <+439>: mov    r13, rax
    0x10000c99a <+442>: call   0x100008de0               ; MixinTest.ThreeNumbers.__allocating_init(a: Swift.Int, b: Swift.Int, c: Swift.Int) -> MixinTest.ThreeNumbers at TestFunctions.swift:64
    0x10000c99f <+447>: mov    qword ptr [rbp - 0x48], rax
    0x10000c9a3 <+451>: mov    rdi, qword ptr [rbp - 0xd8]
    0x10000c9aa <+458>: mov    qword ptr [rbp - 0xf0], rax
    0x10000c9b1 <+465>: call   0x10000e78a               ; symbol stub for: swift_retain
    0x10000c9b6 <+470>: mov    rdi, qword ptr [rbp - 0xf0]
    0x10000c9bd <+477>: mov    r13, qword ptr [rbp - 0xd8]
    0x10000c9c4 <+484>: mov    rcx, qword ptr [rbp - 0xe0]
    0x10000c9cb <+491>: mov    qword ptr [rbp - 0xf8], rax
    0x10000c9d2 <+498>: call   rcx
    0x10000c9d4 <+500>: mov    r13, rdx
    0x10000c9d7 <+503>: mov    qword ptr [rbp - 0x100], rdx
    0x10000c9de <+510>: call   rax
    0x10000c9e0 <+512>: mov    qword ptr [rbp - 0x50], rax
    0x10000c9e4 <+516>: mov    rdi, qword ptr [rbp - 0x100]
    0x10000c9eb <+523>: mov    qword ptr [rbp - 0x108], rax
    0x10000c9f2 <+530>: call   0x10000e784               ; symbol stub for: swift_release
    0x10000c9f7 <+535>: mov    rdi, qword ptr [rbp - 0xd8]
    0x10000c9fe <+542>: call   0x10000e784               ; symbol stub for: swift_release
    0x10000ca03 <+547>: mov    rax, qword ptr [rip + 0x3786] ; (void *)0x00007fff81589a28: type metadata for Any
    0x10000ca0a <+554>: add    rax, 0x8
    0x10000ca10 <+560>: mov    edi, 0x1
    0x10000ca15 <+565>: mov    rsi, rax
    0x10000ca18 <+568>: call   0x10000e6ca               ; symbol stub for: Swift._allocateUninitializedArray<A>(Builtin.Word) -> (Swift.Array<A>, Builtin.RawPointer)
    0x10000ca1d <+573>: mov    edi, 0x5
    0x10000ca22 <+578>: mov    esi, 0x1
    0x10000ca27 <+583>: mov    qword ptr [rbp - 0x110], rax
    0x10000ca2e <+590>: mov    qword ptr [rbp - 0x118], rdx
    0x10000ca35 <+597>: call   0x10000e6c4               ; symbol stub for: Swift.DefaultStringInterpolation.init(literalCapacity: Swift.Int, interpolationCount: Swift.Int) -> Swift.DefaultStringInterpolation
    0x10000ca3a <+602>: mov    qword ptr [rbp - 0x60], rax
    0x10000ca3e <+606>: mov    qword ptr [rbp - 0x58], rdx
    0x10000ca42 <+610>: lea    rdi, [rip + 0x2f50]       ; "sum: "
    0x10000ca49 <+617>: mov    esi, 0x5
    0x10000ca4e <+622>: mov    edx, 0x1
    0x10000ca53 <+627>: call   0x10000e652               ; symbol stub for: Swift.String.init(_builtinStringLiteral: Builtin.RawPointer, utf8CodeUnitCount: Builtin.Word, isASCII: Builtin.Int1) -> Swift.String
    0x10000ca58 <+632>: mov    rdi, rax
    0x10000ca5b <+635>: mov    rsi, rdx
    0x10000ca5e <+638>: lea    r13, [rbp - 0x60]
    0x10000ca62 <+642>: mov    qword ptr [rbp - 0x120], rdx
    0x10000ca69 <+649>: call   0x10000e6be               ; symbol stub for: Swift.DefaultStringInterpolation.appendLiteral(Swift.String) -> ()
    0x10000ca6e <+654>: mov    rdi, qword ptr [rbp - 0x120]
    0x10000ca75 <+661>: call   0x10000e730               ; symbol stub for: swift_bridgeObjectRelease
    0x10000ca7a <+666>: mov    rsi, qword ptr [rip + 0x362f] ; (void *)0x00007fff81581c80: type metadata for Swift.Int
    0x10000ca81 <+673>: mov    rdx, qword ptr [rip + 0x3650] ; (void *)0x00007fff81579cb0: protocol witness table for Swift.Int : Swift.CustomStringConvertible in Swift
    0x10000ca88 <+680>: mov    rax, qword ptr [rbp - 0x108]
    0x10000ca8f <+687>: mov    qword ptr [rbp - 0x68], rax
    0x10000ca93 <+691>: lea    rcx, [rbp - 0x68]
    0x10000ca97 <+695>: mov    rdi, rcx
    0x10000ca9a <+698>: lea    r13, [rbp - 0x60]
    0x10000ca9e <+702>: call   0x10000e6b8               ; symbol stub for: Swift.DefaultStringInterpolation.appendInterpolation<A where A: Swift.CustomStringConvertible>(A) -> ()
    0x10000caa3 <+707>: xor    r8d, r8d
    0x10000caa6 <+710>: mov    esi, r8d
    0x10000caa9 <+713>: lea    rdi, [rip + 0x2c18]       ; ""
    0x10000cab0 <+720>: mov    edx, 0x1
    0x10000cab5 <+725>: call   0x10000e652               ; symbol stub for: Swift.String.init(_builtinStringLiteral: Builtin.RawPointer, utf8CodeUnitCount: Builtin.Word, isASCII: Builtin.Int1) -> Swift.String
    0x10000caba <+730>: mov    rdi, rax
    0x10000cabd <+733>: mov    rsi, rdx
    0x10000cac0 <+736>: lea    r13, [rbp - 0x60]
    0x10000cac4 <+740>: mov    qword ptr [rbp - 0x128], rdx
    0x10000cacb <+747>: call   0x10000e6be               ; symbol stub for: Swift.DefaultStringInterpolation.appendLiteral(Swift.String) -> ()
    0x10000cad0 <+752>: mov    rdi, qword ptr [rbp - 0x128]
    0x10000cad7 <+759>: call   0x10000e730               ; symbol stub for: swift_bridgeObjectRelease
    0x10000cadc <+764>: mov    rdi, qword ptr [rbp - 0x60]
    0x10000cae0 <+768>: mov    rax, qword ptr [rbp - 0x58]
    0x10000cae4 <+772>: mov    qword ptr [rbp - 0x130], rdi
    0x10000caeb <+779>: mov    rdi, rax
    0x10000caee <+782>: mov    qword ptr [rbp - 0x138], rax
    0x10000caf5 <+789>: call   0x10000e736               ; symbol stub for: swift_bridgeObjectRetain
    0x10000cafa <+794>: lea    rdi, [rbp - 0x60]
    0x10000cafe <+798>: mov    qword ptr [rbp - 0x140], rax
    0x10000cb05 <+805>: call   0x10000c360               ; outlined destroy of Swift.DefaultStringInterpolation at <compiler-generated>
    0x10000cb0a <+810>: mov    rdi, qword ptr [rbp - 0x130]
    0x10000cb11 <+817>: mov    rsi, qword ptr [rbp - 0x138]
    0x10000cb18 <+824>: mov    qword ptr [rbp - 0x148], rax
    0x10000cb1f <+831>: call   0x10000e64c               ; symbol stub for: Swift.String.init(stringInterpolation: Swift.DefaultStringInterpolation) -> Swift.String
    0x10000cb24 <+836>: mov    rcx, qword ptr [rip + 0x3565] ; (void *)0x00007fff8157fe00: type metadata for Swift.String
    0x10000cb2b <+843>: mov    rsi, qword ptr [rbp - 0x118]
    0x10000cb32 <+850>: mov    qword ptr [rsi + 0x18], rcx
    0x10000cb36 <+854>: mov    qword ptr [rsi], rax
    0x10000cb39 <+857>: mov    qword ptr [rsi + 0x8], rdx
    0x10000cb3d <+861>: call   0x100005760               ; default argument 1 of Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () at <compiler-generated>
    0x10000cb42 <+866>: mov    qword ptr [rbp - 0x150], rax
    0x10000cb49 <+873>: mov    qword ptr [rbp - 0x158], rdx
    0x10000cb50 <+880>: call   0x100005780               ; default argument 2 of Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () at <compiler-generated>
    0x10000cb55 <+885>: mov    rdi, qword ptr [rbp - 0x110]
    0x10000cb5c <+892>: mov    rsi, qword ptr [rbp - 0x150]
    0x10000cb63 <+899>: mov    rcx, qword ptr [rbp - 0x158]
    0x10000cb6a <+906>: mov    qword ptr [rbp - 0x160], rdx
    0x10000cb71 <+913>: mov    rdx, rcx
    0x10000cb74 <+916>: mov    rcx, rax
    0x10000cb77 <+919>: mov    r8, qword ptr [rbp - 0x160]
    0x10000cb7e <+926>: call   0x10000e6e8               ; symbol stub for: Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> ()
    0x10000cb83 <+931>: mov    rdi, qword ptr [rbp - 0x160]
    0x10000cb8a <+938>: call   0x10000e730               ; symbol stub for: swift_bridgeObjectRelease
    0x10000cb8f <+943>: mov    rdi, qword ptr [rbp - 0x158]
    0x10000cb96 <+950>: call   0x10000e730               ; symbol stub for: swift_bridgeObjectRelease
    0x10000cb9b <+955>: mov    rdi, qword ptr [rbp - 0x110]
    0x10000cba2 <+962>: call   0x10000e730               ; symbol stub for: swift_bridgeObjectRelease
    0x10000cba7 <+967>: mov    rdi, qword ptr [rbp - 0xf0]
    0x10000cbae <+974>: call   0x10000e784               ; symbol stub for: swift_release
    0x10000cbb3 <+979>: mov    rdi, qword ptr [rbp - 0xd8]
    0x10000cbba <+986>: call   0x10000e784               ; symbol stub for: swift_release
    0x10000cbbf <+991>: lea    rsp, [rbp - 0x8]
    0x10000cbc3 <+995>: pop    r13
    0x10000cbc5 <+997>: pop    rbp
    0x10000cbc6 <+998>: ret    
```

# Static struct methods

- 0x100010b80
  - 0x100010b30
    - 0x100010620
      - 0x10000f3b0
        - 0x100010bd0
          - 0x100010640
            - 0x10000bb50 <- actual function

```
(lldb) d -a 0x100010640
MixinTest`implicit closure #2 in implicit closure #1 in main():
    0x100010640 <+0>:  push   rbp
    0x100010641 <+1>:  mov    rbp, rsp
    0x100010644 <+4>:  call   0x10000bb50               ; static MixinTest.TwoNumbers.getNice() -> Swift.Int at TestFunctions.swift:54
    0x100010649 <+9>:  pop    rbp
    0x10001064a <+10>: ret    

(lldb) d -a 0x100010bd0
MixinTest`partial apply for implicit closure #2 in implicit closure #1 in main():
    0x100010bd0 <+0>: push   rbp
    0x100010bd1 <+1>: mov    rbp, rsp
    0x100010bd4 <+4>: pop    rbp
    0x100010bd5 <+5>: jmp    0x100010640               ; implicit closure #2 () -> Swift.Int in implicit closure #1 (MixinTest.TwoNumbers.Type) -> () -> Swift.Int in MixinTest.main() -> () at main.swift
    
(lldb) d -a 0x10000f3b0
MixinTest`thunk for @escaping @callee_guaranteed () -> (@unowned Int):
    0x10000f3b0 <+0>:  push   rbp
    0x10000f3b1 <+1>:  mov    rbp, rsp
    0x10000f3b4 <+4>:  push   r13
    0x10000f3b6 <+6>:  push   rax
    0x10000f3b7 <+7>:  mov    r13, rsi
    0x10000f3ba <+10>: mov    qword ptr [rbp - 0x10], rax
    0x10000f3be <+14>: call   rdi
    0x10000f3c0 <+16>: mov    rcx, qword ptr [rbp - 0x10]
    0x10000f3c4 <+20>: mov    qword ptr [rcx], rax
    0x10000f3c7 <+23>: add    rsp, 0x8
    0x10000f3cb <+27>: pop    r13
    0x10000f3cd <+29>: pop    rbp
    0x10000f3ce <+30>: ret    

(lldb) d -a 0x100010620
MixinTest`partial apply for thunk for @escaping @callee_guaranteed () -> (@unowned Int):
    0x100010620 <+0>:  push   rbp
    0x100010621 <+1>:  mov    rbp, rsp
    0x100010624 <+4>:  mov    rdi, qword ptr [r13 + 0x10]
    0x100010628 <+8>:  mov    rsi, qword ptr [r13 + 0x18]
    0x10001062c <+12>: call   0x10000f3b0               ; reabstraction thunk helper from @escaping @callee_guaranteed () -> (@unowned Swift.Int) to @escaping @callee_guaranteed () -> (@out Swift.Int) at <compiler-generated>
    0x100010631 <+17>: pop    rbp
    0x100010632 <+18>: ret    

(lldb) d -a 0x100010b30
MixinTest`thunk for @escaping @callee_guaranteed () -> (@out Int):
    0x100010b30 <+0>:  push   rbp
    0x100010b31 <+1>:  mov    rbp, rsp
    0x100010b34 <+4>:  push   r13
    0x100010b36 <+6>:  push   rax
    0x100010b37 <+7>:  lea    rax, [rbp - 0x10]
    0x100010b3b <+11>: mov    r13, rsi
    0x100010b3e <+14>: call   rdi
    0x100010b40 <+16>: mov    rax, qword ptr [rbp - 0x10]
    0x100010b44 <+20>: add    rsp, 0x8
    0x100010b48 <+24>: pop    r13
    0x100010b4a <+26>: pop    rbp
    0x100010b4b <+27>: ret    

(lldb) d -a 0x100010b80
MixinTest`partial apply for thunk for @escaping @callee_guaranteed () -> (@out Int):
    0x100010b80 <+0>:  push   rbp
    0x100010b81 <+1>:  mov    rbp, rsp
    0x100010b84 <+4>:  mov    rdi, qword ptr [r13 + 0x10]
    0x100010b88 <+8>:  mov    rsi, qword ptr [r13 + 0x18]
    0x100010b8c <+12>: pop    rbp
    0x100010b8d <+13>: jmp    0x100010b30               ; reabstraction thunk helper from @escaping @callee_guaranteed () -> (@out Swift.Int) to @escaping @callee_guaranteed () -> (@unowned Swift.Int) at <compiler-generated>
(lldb) 
```

```
(lldb) d -n runStatic
MixinTest`runStatic<T>(_:):
    0x100010650 <+0>:   push   rbp
    0x100010651 <+1>:   mov    rbp, rsp
    0x100010654 <+4>:   push   r13
    0x100010656 <+6>:   sub    rsp, 0x128
    0x10001065d <+13>:  mov    qword ptr [rbp - 0x18], 0x0
    0x100010665 <+21>:  xorps  xmm0, xmm0
    0x100010668 <+24>:  movaps xmmword ptr [rbp - 0x40], xmm0
    0x10001066c <+28>:  movaps xmmword ptr [rbp - 0x50], xmm0
    0x100010670 <+32>:  mov    qword ptr [rbp - 0x10], rsi
    0x100010674 <+36>:  mov    rax, qword ptr [rsi - 0x8]
    0x100010678 <+40>:  mov    rcx, qword ptr [rax + 0x40]
    0x10001067c <+44>:  add    rcx, 0xf
    0x100010680 <+48>:  and    rcx, -0x10
    0x100010684 <+52>:  mov    rdx, rsp
    0x100010687 <+55>:  sub    rdx, rcx
    0x10001068a <+58>:  mov    rsp, rdx
    0x10001068d <+61>:  mov    qword ptr [rbp - 0x18], rdi
    0x100010691 <+65>:  mov    qword ptr [rbp - 0x60], rdi
    0x100010695 <+69>:  mov    rdi, rdx
    0x100010698 <+72>:  mov    rcx, qword ptr [rbp - 0x60]
    0x10001069c <+76>:  mov    qword ptr [rbp - 0x68], rsi
    0x1000106a0 <+80>:  mov    rsi, rcx
    0x1000106a3 <+83>:  mov    r8, qword ptr [rbp - 0x68]
    0x1000106a7 <+87>:  mov    qword ptr [rbp - 0x70], rdx
    0x1000106ab <+91>:  mov    rdx, r8
    0x1000106ae <+94>:  call   qword ptr [rax + 0x10]
    0x1000106b1 <+97>:  lea    rcx, [rbp - 0x28]
    0x1000106b5 <+101>: lea    rdi, [rip + 0x7ef4]       ; demangling cache variable for type metadata for () -> Swift.Int
    0x1000106bc <+108>: mov    qword ptr [rbp - 0x78], rax
    0x1000106c0 <+112>: mov    qword ptr [rbp - 0x80], rcx
    0x1000106c4 <+116>: call   0x100006c10               ; __swift_instantiateConcreteTypeFromMangledName at <compiler-generated>
    0x1000106c9 <+121>: mov    rdi, qword ptr [rbp - 0x80]
    0x1000106cd <+125>: mov    rsi, qword ptr [rbp - 0x70]
    0x1000106d1 <+129>: mov    rdx, qword ptr [rbp - 0x68]
    0x1000106d5 <+133>: mov    rcx, rax
    0x1000106d8 <+136>: mov    r8d, 0x6
    0x1000106de <+142>: call   0x100012606               ; symbol stub for: swift_dynamicCast
    0x1000106e3 <+147>: test   al, 0x1
    0x1000106e5 <+149>: jne    0x1000106e9               ; <+153> at main.swift
    0x1000106e7 <+151>: jmp    0x10001074e               ; <+254> at main.swift
    0x1000106e9 <+153>: lea    rax, [rip + 0x41c8]       ; type metadata for MixinTest.Numbers + 856
    0x1000106f0 <+160>: add    rax, 0x10
    0x1000106f6 <+166>: mov    rcx, qword ptr [rbp - 0x28]
    0x1000106fa <+170>: mov    rdx, qword ptr [rbp - 0x20]
    0x1000106fe <+174>: mov    rdi, rax
    0x100010701 <+177>: mov    esi, 0x20
    0x100010706 <+182>: mov    eax, 0x7
    0x10001070b <+187>: mov    qword ptr [rbp - 0x88], rdx
    0x100010712 <+194>: mov    rdx, rax
    0x100010715 <+197>: mov    qword ptr [rbp - 0x90], rcx
    0x10001071c <+204>: call   0x1000125e2               ; symbol stub for: swift_allocObject
    0x100010721 <+209>: mov    rcx, qword ptr [rbp - 0x90]
    0x100010728 <+216>: mov    qword ptr [rax + 0x10], rcx
    0x10001072c <+220>: mov    rcx, qword ptr [rbp - 0x88]
    0x100010733 <+227>: mov    qword ptr [rax + 0x18], rcx
    0x100010737 <+231>: lea    rcx, [rip + 0x442]        ; partial apply forwarder for reabstraction thunk helper from @escaping @callee_guaranteed () -> (@out Swift.Int) to @escaping @callee_guaranteed () -> (@unowned Swift.Int) at <compiler-generated>
    0x10001073e <+238>: mov    qword ptr [rbp - 0x98], rcx
    0x100010745 <+245>: mov    qword ptr [rbp - 0xa0], rax
    0x10001074c <+252>: jmp    0x100010763               ; <+275> at main.swift
    0x10001074e <+254>: xor    eax, eax
    0x100010750 <+256>: mov    ecx, eax
    0x100010752 <+258>: mov    rdx, rcx
    0x100010755 <+261>: mov    qword ptr [rbp - 0x98], rdx
    0x10001075c <+268>: mov    qword ptr [rbp - 0xa0], rcx
    0x100010763 <+275>: mov    rax, qword ptr [rbp - 0xa0]
    0x10001076a <+282>: mov    rcx, qword ptr [rbp - 0x98]
    0x100010771 <+289>: cmp    rcx, 0x0
    0x100010775 <+293>: mov    qword ptr [rbp - 0xa8], rax
    0x10001077c <+300>: mov    qword ptr [rbp - 0xb0], rcx
    0x100010783 <+307>: je     0x1000107a3               ; <+339> at main.swift:109:38
    0x100010785 <+309>: mov    rax, qword ptr [rbp - 0xb0]
    0x10001078c <+316>: mov    rcx, qword ptr [rbp - 0xa8]
    0x100010793 <+323>: mov    qword ptr [rbp - 0xb8], rax
    0x10001079a <+330>: mov    qword ptr [rbp - 0xc0], rcx
    0x1000107a1 <+337>: jmp    0x1000107a8               ; <+344> at main.swift
    0x1000107a3 <+339>: jmp    0x1000109a5               ; <+853> at main.swift:112:1
    0x1000107a8 <+344>: mov    rax, qword ptr [rbp - 0xc0]
    0x1000107af <+351>: mov    rcx, qword ptr [rbp - 0xb8]
    0x1000107b6 <+358>: mov    rdx, qword ptr [rip + 0x3a0b] ; (void *)0x00007fff81589a28: type metadata for Any
    0x1000107bd <+365>: add    rdx, 0x8
    0x1000107c4 <+372>: mov    qword ptr [rbp - 0x40], rcx
    0x1000107c8 <+376>: mov    qword ptr [rbp - 0x38], rax
    0x1000107cc <+380>: mov    edi, 0x1
    0x1000107d1 <+385>: mov    rsi, rdx
    0x1000107d4 <+388>: mov    qword ptr [rbp - 0xc8], rax
    0x1000107db <+395>: mov    qword ptr [rbp - 0xd0], rcx
    0x1000107e2 <+402>: call   0x100012582               ; symbol stub for: Swift._allocateUninitializedArray<A>(Builtin.Word) -> (Swift.Array<A>, Builtin.RawPointer)
    0x1000107e7 <+407>: mov    edi, 0x8
    0x1000107ec <+412>: mov    esi, 0x1
    0x1000107f1 <+417>: mov    qword ptr [rbp - 0xd8], rax
    0x1000107f8 <+424>: mov    qword ptr [rbp - 0xe0], rdx
    0x1000107ff <+431>: call   0x10001257c               ; symbol stub for: Swift.DefaultStringInterpolation.init(literalCapacity: Swift.Int, interpolationCount: Swift.Int) -> Swift.DefaultStringInterpolation
    0x100010804 <+436>: mov    qword ptr [rbp - 0x50], rax
    0x100010808 <+440>: mov    qword ptr [rbp - 0x48], rdx
    0x10001080c <+444>: lea    rdi, [rip + 0x30d6]       ; "result: "
    0x100010813 <+451>: mov    esi, 0x8
    0x100010818 <+456>: mov    edx, 0x1
    0x10001081d <+461>: call   0x1000124fe               ; symbol stub for: Swift.String.init(_builtinStringLiteral: Builtin.RawPointer, utf8CodeUnitCount: Builtin.Word, isASCII: Builtin.Int1) -> Swift.String
    0x100010822 <+466>: mov    rdi, rax
    0x100010825 <+469>: mov    rsi, rdx
    0x100010828 <+472>: lea    r13, [rbp - 0x50]
    0x10001082c <+476>: mov    qword ptr [rbp - 0xe8], rdx
    0x100010833 <+483>: call   0x100012576               ; symbol stub for: Swift.DefaultStringInterpolation.appendLiteral(Swift.String) -> ()
    0x100010838 <+488>: mov    rdi, qword ptr [rbp - 0xe8]
    0x10001083f <+495>: call   0x1000125ee               ; symbol stub for: swift_bridgeObjectRelease
    0x100010844 <+500>: mov    rdi, qword ptr [rbp - 0xc8]
    0x10001084b <+507>: call   0x100012648               ; symbol stub for: swift_retain
    0x100010850 <+512>: mov    r13, qword ptr [rbp - 0xc8]
    0x100010857 <+519>: mov    rcx, qword ptr [rbp - 0xd0]
    0x10001085e <+526>: mov    qword ptr [rbp - 0xf0], rax
    0x100010865 <+533>: call   rcx
    0x100010867 <+535>: mov    rsi, qword ptr [rip + 0x384a] ; (void *)0x00007fff81581c80: type metadata for Swift.Int
    0x10001086e <+542>: mov    rdx, qword ptr [rip + 0x386b] ; (void *)0x00007fff81579cb0: protocol witness table for Swift.Int : Swift.CustomStringConvertible in Swift
    0x100010875 <+549>: mov    qword ptr [rbp - 0x58], rax
    0x100010879 <+553>: lea    rax, [rbp - 0x58]
    0x10001087d <+557>: mov    rdi, rax
    0x100010880 <+560>: lea    r13, [rbp - 0x50]
    0x100010884 <+564>: call   0x100012570               ; symbol stub for: Swift.DefaultStringInterpolation.appendInterpolation<A where A: Swift.CustomStringConvertible>(A) -> ()
    0x100010889 <+569>: mov    rdi, qword ptr [rbp - 0xc8]
    0x100010890 <+576>: call   0x100012642               ; symbol stub for: swift_release
    0x100010895 <+581>: xor    r8d, r8d
    0x100010898 <+584>: mov    esi, r8d
    0x10001089b <+587>: lea    rdi, [rip + 0x2d16]       ; ""
    0x1000108a2 <+594>: mov    edx, 0x1
    0x1000108a7 <+599>: call   0x1000124fe               ; symbol stub for: Swift.String.init(_builtinStringLiteral: Builtin.RawPointer, utf8CodeUnitCount: Builtin.Word, isASCII: Builtin.Int1) -> Swift.String
    0x1000108ac <+604>: mov    rdi, rax
    0x1000108af <+607>: mov    rsi, rdx
    0x1000108b2 <+610>: lea    r13, [rbp - 0x50]
    0x1000108b6 <+614>: mov    qword ptr [rbp - 0xf8], rdx
    0x1000108bd <+621>: call   0x100012576               ; symbol stub for: Swift.DefaultStringInterpolation.appendLiteral(Swift.String) -> ()
    0x1000108c2 <+626>: mov    rdi, qword ptr [rbp - 0xf8]
    0x1000108c9 <+633>: call   0x1000125ee               ; symbol stub for: swift_bridgeObjectRelease
    0x1000108ce <+638>: mov    rdi, qword ptr [rbp - 0x50]
    0x1000108d2 <+642>: mov    rax, qword ptr [rbp - 0x48]
    0x1000108d6 <+646>: mov    qword ptr [rbp - 0x100], rdi
    0x1000108dd <+653>: mov    rdi, rax
    0x1000108e0 <+656>: mov    qword ptr [rbp - 0x108], rax
    0x1000108e7 <+663>: call   0x1000125f4               ; symbol stub for: swift_bridgeObjectRetain
    0x1000108ec <+668>: lea    rdi, [rbp - 0x50]
    0x1000108f0 <+672>: mov    qword ptr [rbp - 0x110], rax
    0x1000108f7 <+679>: call   0x100010140               ; outlined destroy of Swift.DefaultStringInterpolation at <compiler-generated>
    0x1000108fc <+684>: mov    rdi, qword ptr [rbp - 0x100]
    0x100010903 <+691>: mov    rsi, qword ptr [rbp - 0x108]
    0x10001090a <+698>: mov    qword ptr [rbp - 0x118], rax
    0x100010911 <+705>: call   0x1000124f8               ; symbol stub for: Swift.String.init(stringInterpolation: Swift.DefaultStringInterpolation) -> Swift.String
    0x100010916 <+710>: mov    rcx, qword ptr [rip + 0x377b] ; (void *)0x00007fff8157fe00: type metadata for Swift.String
    0x10001091d <+717>: mov    rsi, qword ptr [rbp - 0xe0]
    0x100010924 <+724>: mov    qword ptr [rsi + 0x18], rcx
    0x100010928 <+728>: mov    qword ptr [rsi], rax
    0x10001092b <+731>: mov    qword ptr [rsi + 0x8], rdx
    0x10001092f <+735>: call   0x1000064d0               ; default argument 1 of Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () at <compiler-generated>
    0x100010934 <+740>: mov    qword ptr [rbp - 0x120], rax
    0x10001093b <+747>: mov    qword ptr [rbp - 0x128], rdx
    0x100010942 <+754>: call   0x1000064f0               ; default argument 2 of Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () at <compiler-generated>
    0x100010947 <+759>: mov    rdi, qword ptr [rbp - 0xd8]
    0x10001094e <+766>: mov    rsi, qword ptr [rbp - 0x120]
    0x100010955 <+773>: mov    rcx, qword ptr [rbp - 0x128]
    0x10001095c <+780>: mov    qword ptr [rbp - 0x130], rdx
    0x100010963 <+787>: mov    rdx, rcx
    0x100010966 <+790>: mov    rcx, rax
    0x100010969 <+793>: mov    r8, qword ptr [rbp - 0x130]
    0x100010970 <+800>: call   0x1000125a0               ; symbol stub for: Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> ()
    0x100010975 <+805>: mov    rdi, qword ptr [rbp - 0x130]
    0x10001097c <+812>: call   0x1000125ee               ; symbol stub for: swift_bridgeObjectRelease
    0x100010981 <+817>: mov    rdi, qword ptr [rbp - 0x128]
    0x100010988 <+824>: call   0x1000125ee               ; symbol stub for: swift_bridgeObjectRelease
    0x10001098d <+829>: mov    rdi, qword ptr [rbp - 0xd8]
    0x100010994 <+836>: call   0x1000125ee               ; symbol stub for: swift_bridgeObjectRelease
    0x100010999 <+841>: mov    rdi, qword ptr [rbp - 0xc8]
    0x1000109a0 <+848>: call   0x100012642               ; symbol stub for: swift_release
    0x1000109a5 <+853>: lea    rsp, [rbp - 0x8]
    0x1000109a9 <+857>: pop    r13
    0x1000109ab <+859>: pop    rbp
    0x1000109ac <+860>: ret    
```