# Path of RCX

- from `qword ptr [rbp - 0xb8]`
- from `qword ptr [rbp - 0xa0]`
- from `qword ptr [rbp - 0x98]`
- from `qword ptr [rbp - 0x80]`
- from `lea [rip + 0x302]`

# Path of RDI

- from `qword ptr [r13 + 0x10]`
- `r13` is from `rsi`
- `rsi` is from `qword ptr [r13 + 0x18]`
- `r13` is from `qword ptr [rbp - 0xb0]`
- `qword ptr [rbp - 0xb0]` is from `rax`
- `rax` is from `qword ptr [rbp - 0xa8]`
- `qword ptr [rbp - 0xa8]` is from `rcx`
- `rcx` is from `qword ptr [rbp - 0x90]`
- `qword ptr [rbp - 0x90]` is from `rax`
- `rax` is from `qword ptr [rbp - 0x88]`
- `qword ptr [rbp - 0x88]` is from `rax`


# 0x1000035a8 : structure of memory at r13

+ 0x10: pointer to `MixinTest`partial apply for thunk for @escaping @callee_guaranteed () -> (@out ())` <- `rbp - 0x78`
+ 0x18: pointer to memory { <- `rbp - 0x70`
    + 0x10: `function2`
  }

# Struct methods


<!-- 0x100006960 contains the call to TwoNumbers.sum() -->

- first `call rax`
  - 0x000000010000aec0: partial apply forwarder for reabstraction thunk helper from @escaping @callee_guaranteed (@in_guaranteed MixinTest.TwoNumbers) -> (@out @escaping @callee_guaranteed @substituted <A> () -> (@out A) for <Swift.Int>) to @escaping @callee_guaranteed (@unowned MixinTest.TwoNumbers) -> (@owned @escaping @callee_guaranteed () -> (@unowned Swift.Int)) at <compiler-generated>
    - 0x10000ae20: reabstraction thunk helper from @escaping @callee_guaranteed (@in_guaranteed MixinTest.TwoNumbers) -> (@out @escaping @callee_guaranteed @substituted <A> () -> (@out A) for <Swift.Int>) to @escaping @callee_guaranteed (@unowned MixinTest.TwoNumbers) -> (@owned @escaping @callee_guaranteed () -> (@unowned Swift.Int)) at <compiler-generated>
      - 0x000000010000aa30: partial apply forwarder for reabstraction thunk helper from @escaping @callee_guaranteed (@unowned MixinTest.TwoNumbers) -> (@owned @escaping @callee_guaranteed () -> (@unowned Swift.Int)) to @escaping @callee_guaranteed (@in_guaranteed MixinTest.TwoNumbers) -> (@out @escaping @callee_guaranteed @substituted <A> () -> (@out A) for <Swift.Int>) at <compiler-generated>
        - 0x10000a980: reabstraction thunk helper from @escaping @callee_guaranteed (@unowned MixinTest.TwoNumbers) -> (@owned @escaping @callee_guaranteed () -> (@unowned Swift.Int)) to @escaping @callee_guaranteed (@in_guaranteed MixinTest.TwoNumbers) -> (@out @escaping @callee_guaranteed @substituted <A> () -> (@out A) for <Swift.Int>) at <compiler-generated>
          - 0x10000a8e0: implicit closure #1 in main()
      - Returns a `partial apply forwarder for reabstraction thunk helper from @escaping @callee_guaranteed () -> (@out Swift.Int) to @escaping @callee_guaranteed () -> (@unowned Swift.Int) at <compiler-generated>` in rax and an allocated object in rdx


- second `call rax`
  - 0x10000af10: partial apply for thunk for @escaping @callee_guaranteed () -> (@out Int)
    - 0x1000077a0: reabstraction thunk helper from @escaping @callee_guaranteed () -> (@out Swift.Int) to @escaping @callee_guaranteed () -> (@unowned Swift.Int) at <compiler-generated>
      - 0x000000010000af60: partial apply forwarder for reabstraction thunk helper from @escaping @callee_guaranteed () -> (@unowned Swift.Int) to @escaping @callee_guaranteed () -> (@out Swift.Int) at <compiler-generated>
        - 0x10000aa50: reabstraction thunk helper from @escaping @callee_guaranteed () -> (@unowned Swift.Int) to @escaping @callee_guaranteed () -> (@out Swift.Int) at <compiler-generated>
          - 0x000000010000afa0: partial apply forwarder for implicit closure #2 () -> Swift.Int in implicit closure #1 (MixinTest.TwoNumbers) -> () -> Swift.Int in MixinTest.main() -> () at <compiler-generated>
            - 0x10000a950: implicit closure #2 () -> Swift.Int in implicit closure #1 (MixinTest.TwoNumbers) -> () -> Swift.Int in MixinTest.main() -> () at main.swift
              - 0x100009090: MixinTest.TwoNumbers.sum() -> Swift.Int at TestFunctions.swift




- first
  - 0x000000010000ae60
    - 0x10000adc0
      - 0x000000010000a8e0
        - 0x10000a830
          - 0x000000010000a790
- second
  - 0x000000010000aeb0
    - 0x1000075e0
      - 0x000000010000af40
        - 0x10000a900 
          - 0x000000010000af80
            - 0x10000a800
              - actual function: 0x100008ed0  

- first
  - 0x000000010000ae60
    - 0x10000adc0
      - 0x10000ad70
        - 0x10000a830
          - 0x000000010000acd0
- second
  - 0x000000010000aeb0
    - 0x1000075e0
      - 0x10000af40
        - 0x10000a900
          - 0x10000aef0
            - 0x10000ad90 
              - actual function: 0x100008ed0 



(lldb) d -s 0x10000ad90
MixinTest`implicit closure #4 in implicit closure #3 in main():
    0x10000ad90 <+0>:  push   rbp
    0x10000ad91 <+1>:  mov    rbp, rsp
    0x10000ad94 <+4>:  sub    rsp, 0x10
->  0x10000ad98 <+8>:  xorps  xmm0, xmm0
    0x10000ad9b <+11>: movaps xmmword ptr [rbp - 0x10], xmm0
    0x10000ad9f <+15>: mov    qword ptr [rbp - 0x10], rdi
    0x10000ada3 <+19>: mov    qword ptr [rbp - 0x8], rsi
    0x10000ada7 <+23>: call   0x100008ed0               ; MixinTest.TwoNumbers.sum() -> Swift.Int at TestFunctions.swift:41
    0x10000adac <+28>: add    rsp, 0x10

(lldb) d -s 0x10000aef0
MixinTest`partial apply for implicit closure #4 in implicit closure #3 in main():
    0x10000aef0 <+0>:  push   rbp
    0x10000aef1 <+1>:  mov    rbp, rsp
    0x10000aef4 <+4>:  mov    rdi, qword ptr [r13 + 0x10]
    0x10000aef8 <+8>:  mov    rsi, qword ptr [r13 + 0x18]
    0x10000aefc <+12>: pop    rbp
    0x10000aefd <+13>: jmp    0x10000ad90               ; implicit closure #4 () -> Swift.Int in implicit closure #3 (MixinTest.TwoNumbers) -> () -> Swift.Int in MixinTest.main() -> () at main.swift
    0x10000af02 <+18>: nop    word ptr cs:[rax + rax]
    0x10000af0c <+28>: nop    dword ptr [rax]

(lldb) d -s 0x10000a900
MixinTest`thunk for @escaping @callee_guaranteed () -> (@unowned Int):
    0x10000a900 <+0>:  push   rbp
    0x10000a901 <+1>:  mov    rbp, rsp
    0x10000a904 <+4>:  push   r13
    0x10000a906 <+6>:  push   rax
    0x10000a907 <+7>:  mov    r13, rsi
    0x10000a90a <+10>: mov    qword ptr [rbp - 0x10], rax
    0x10000a90e <+14>: call   rdi
    0x10000a910 <+16>: mov    rcx, qword ptr [rbp - 0x10]
    0x10000a914 <+20>: mov    qword ptr [rcx], rax
    0x10000a917 <+23>: add    rsp, 0x8
    0x10000a91b <+27>: pop    r13
    0x10000a91d <+29>: pop    rbp
    0x10000a91e <+30>: ret    
    0x10000a91f <+31>: nop    

(lldb) d -s 0x10000af40
MixinTest`partial apply for thunk for @escaping @callee_guaranteed () -> (@unowned Int):
    0x10000af40 <+0>:  push   rbp
    0x10000af41 <+1>:  mov    rbp, rsp
    0x10000af44 <+4>:  mov    rdi, qword ptr [r13 + 0x10]
    0x10000af48 <+8>:  mov    rsi, qword ptr [r13 + 0x18]
    0x10000af4c <+12>: call   0x10000a900               ; reabstraction thunk helper from @escaping @callee_guaranteed () -> (@unowned Swift.Int) to @escaping @callee_guaranteed () -> (@out Swift.Int) at <compiler-generated>
    0x10000af51 <+17>: pop    rbp
    0x10000af52 <+18>: ret    
    0x10000af53 <+19>: nop    word ptr cs:[rax + rax]
    0x10000af5d <+29>: nop    dword ptr [rax]

(lldb) d -s 0x1000075e0
MixinTest`thunk for @escaping @callee_guaranteed () -> (@out Int):
    0x1000075e0 <+0>:  push   rbp
    0x1000075e1 <+1>:  mov    rbp, rsp
    0x1000075e4 <+4>:  push   r13
    0x1000075e6 <+6>:  push   rax
    0x1000075e7 <+7>:  lea    rax, [rbp - 0x10]
    0x1000075eb <+11>: mov    r13, rsi
    0x1000075ee <+14>: call   rdi
    0x1000075f0 <+16>: mov    rax, qword ptr [rbp - 0x10]
    0x1000075f4 <+20>: add    rsp, 0x8
    0x1000075f8 <+24>: pop    r13
    0x1000075fa <+26>: pop    rbp
    0x1000075fb <+27>: ret    
    0x1000075fc <+28>: nop    dword ptr [rax]

(lldb) d -s 0x000000010000aeb0
MixinTest`partial apply for thunk for @escaping @callee_guaranteed () -> (@out Int):
    0x10000aeb0 <+0>:  push   rbp
    0x10000aeb1 <+1>:  mov    rbp, rsp
    0x10000aeb4 <+4>:  mov    rdi, qword ptr [r13 + 0x10]
    0x10000aeb8 <+8>:  mov    rsi, qword ptr [r13 + 0x18]
    0x10000aebc <+12>: pop    rbp
    0x10000aebd <+13>: jmp    0x1000075e0               ; reabstraction thunk helper from @escaping @callee_guaranteed () -> (@out Swift.Int) to @escaping @callee_guaranteed () -> (@unowned Swift.Int) at <compiler-generated>
    0x10000aec2 <+18>: nop    word ptr cs:[rax + rax]
    0x10000aecc <+28>: nop    dword ptr [rax]
(lldb) second
error: 'second' is not a valid command.


(lldb) first
error: 'first' is not a valid command.
(lldb) d -s 0x10000a790
MixinTest`implicit closure #1 in main():
    0x10000a790 <+0>:  push   rbp
    0x10000a791 <+1>:  mov    rbp, rsp
    0x10000a794 <+4>:  sub    rsp, 0x30
    0x10000a798 <+8>:  xorps  xmm0, xmm0
    0x10000a79b <+11>: movaps xmmword ptr [rbp - 0x10], xmm0
    0x10000a79f <+15>: mov    qword ptr [rbp - 0x10], rdi
    0x10000a7a3 <+19>: mov    qword ptr [rbp - 0x8], rsi
    0x10000a7a7 <+23>: lea    rax, [rip + 0x6332]       ; type metadata for MixinTest.TwoNumbers + 520
    0x10000a7ae <+30>: mov    ecx, 0x20
    0x10000a7b3 <+35>: mov    edx, 0x7
    0x10000a7b8 <+40>: mov    qword ptr [rbp - 0x18], rdi
    0x10000a7bc <+44>: mov    rdi, rax
    0x10000a7bf <+47>: mov    qword ptr [rbp - 0x20], rsi
    0x10000a7c3 <+51>: mov    rsi, rcx
    0x10000a7c6 <+54>: call   0x10000e51c               ; symbol stub for: swift_allocObject
    0x10000a7cb <+59>: mov    rcx, qword ptr [rbp - 0x18]
    0x10000a7cf <+63>: mov    qword ptr [rax + 0x10], rcx
    0x10000a7d3 <+67>: mov    rdx, qword ptr [rbp - 0x20]
    0x10000a7d7 <+71>: mov    qword ptr [rax + 0x18], rdx
    0x10000a7db <+75>: lea    rsi, [rip + 0x79e]        ; partial apply forwarder for implicit closure #2 () -> Swift.Int in implicit closure #1 (MixinTest.TwoNumbers) -> () -> Swift.Int in MixinTest.main() -> () at <compiler-generated>
    0x10000a7e2 <+82>: mov    qword ptr [rbp - 0x28], rax
    0x10000a7e6 <+86>: mov    rax, rsi
    0x10000a7e9 <+89>: mov    rdx, qword ptr [rbp - 0x28]
    0x10000a7ed <+93>: add    rsp, 0x30
    0x10000a7f1 <+97>: pop    rbp
    0x10000a7f2 <+98>: ret 

(lldb) d -s 0x10000a830
MixinTest`thunk for @escaping @callee_guaranteed (@unowned TwoNumbers) -> (@owned @escaping @callee_guaranteed () -> (@unowned Int)):
0x10000a830 <+0>:   push   rbp
    0x10000a831 <+1>:   mov    rbp, rsp
    0x10000a834 <+4>:   push   r13
    0x10000a836 <+6>:   sub    rsp, 0x28
    0x10000a83a <+10>:  mov    rcx, qword ptr [rdi]
    0x10000a83d <+13>:  mov    rdi, qword ptr [rdi + 0x8]
    0x10000a841 <+17>:  mov    qword ptr [rbp - 0x10], rdi
    0x10000a845 <+21>:  mov    rdi, rcx
    0x10000a848 <+24>:  mov    rcx, qword ptr [rbp - 0x10]
    0x10000a84c <+28>:  mov    qword ptr [rbp - 0x18], rsi
    0x10000a850 <+32>:  mov    rsi, rcx
    0x10000a853 <+35>:  mov    r13, rdx
    0x10000a856 <+38>:  mov    rdx, qword ptr [rbp - 0x18]
    0x10000a85a <+42>:  mov    qword ptr [rbp - 0x20], rax
    0x10000a85e <+46>:  call   rdx
    0x10000a860 <+48>:  lea    rdi, [rip + 0x6251]       ; type metadata for MixinTest.TwoNumbers + 480
    0x10000a867 <+55>:  mov    esi, 0x20
    0x10000a86c <+60>:  mov    ecx, 0x7
    0x10000a871 <+65>:  mov    qword ptr [rbp - 0x28], rdx
    0x10000a875 <+69>:  mov    rdx, rcx
    0x10000a878 <+72>:  mov    qword ptr [rbp - 0x30], rax
    0x10000a87c <+76>:  call   0x10000e51c               ; symbol stub for: swift_allocObject
    0x10000a881 <+81>:  mov    rcx, qword ptr [rbp - 0x30]
    0x10000a885 <+85>:  mov    qword ptr [rax + 0x10], rcx
    0x10000a889 <+89>:  mov    rdx, qword ptr [rbp - 0x28]
    0x10000a88d <+93>:  mov    qword ptr [rax + 0x18], rdx
    0x10000a891 <+97>:  lea    rsi, [rip + 0x6a8]        ; partial apply forwarder for reabstraction thunk helper from @escaping @callee_guaranteed () -> (@unowned Swift.Int) to @escaping @callee_guaranteed () -> (@out Swift.Int) at <compiler-generated>
    0x10000a898 <+104>: mov    rdi, qword ptr [rbp - 0x20]
    0x10000a89c <+108>: mov    qword ptr [rdi], rsi
    0x10000a89f <+111>: mov    qword ptr [rdi + 0x8], rax
    0x10000a8a3 <+115>: add    rsp, 0x28
    0x10000a8a7 <+119>: pop    r13
    0x10000a8a9 <+121>: pop    rbp
    0x10000a8aa <+122>: ret    
    0x10000a8ab <+123>: nop    dword ptr [rax + rax]

(lldb) d -s 0x10000ad70
MixinTest`thunk for @escaping @callee_guaranteed (@unowned TwoNumbers) -> (@owned @escaping @callee_guaranteed () -> (@unowned Int))partial apply:
    0x10000ad70 <+0>:  push   rbp
    0x10000ad71 <+1>:  mov    rbp, rsp
    0x10000ad74 <+4>:  mov    rsi, qword ptr [r13 + 0x10]
    0x10000ad78 <+8>:  mov    rdx, qword ptr [r13 + 0x18]
    0x10000ad7c <+12>: call   0x10000a830               ; reabstraction thunk helper from @escaping @callee_guaranteed (@unowned MixinTest.TwoNumbers) -> (@owned @escaping @callee_guaranteed () -> (@unowned Swift.Int)) to @escaping @callee_guaranteed (@in_guaranteed MixinTest.TwoNumbers) -> (@out @escaping @callee_guaranteed @substituted <A> () -> (@out A) for <Swift.Int>) at <compiler-generated>
    0x10000ad81 <+17>: pop    rbp
    0x10000ad82 <+18>: ret    
    0x10000ad83 <+19>: nop    word ptr cs:[rax + rax]
    0x10000ad8d <+29>: nop    dword ptr [rax]

(lldb) d -s 0x10000adc0
MixinTest`thunk for @escaping @callee_guaranteed (@in_guaranteed TwoNumbers) -> (@out @escaping @callee_guaranteed @substituted <A> () -> (@out A) for <Int>):
    0x10000adc0 <+0>:   push   rbp
    0x10000adc1 <+1>:   mov    rbp, rsp
    0x10000adc4 <+4>:   push   r13
    0x10000adc6 <+6>:   sub    rsp, 0x38
    0x10000adca <+10>:  mov    qword ptr [rbp - 0x18], rdi
    0x10000adce <+14>:  mov    qword ptr [rbp - 0x10], rsi
    0x10000add2 <+18>:  lea    rax, [rbp - 0x28]
    0x10000add6 <+22>:  lea    rdi, [rbp - 0x18]
    0x10000adda <+26>:  mov    r13, rcx
    0x10000addd <+29>:  call   rdx
    0x10000addf <+31>:  mov    rax, qword ptr [rbp - 0x28]
    0x10000ade3 <+35>:  mov    rcx, qword ptr [rbp - 0x20]
    0x10000ade7 <+39>:  lea    rdi, [rip + 0x5c7a]       ; type metadata for MixinTest.TwoNumbers + 400
    0x10000adee <+46>:  mov    esi, 0x20
    0x10000adf3 <+51>:  mov    edx, 0x7
    0x10000adf8 <+56>:  mov    qword ptr [rbp - 0x30], rax
    0x10000adfc <+60>:  mov    qword ptr [rbp - 0x38], rcx
    0x10000ae00 <+64>:  call   0x10000e51c               ; symbol stub for: swift_allocObject
    0x10000ae05 <+69>:  mov    rcx, qword ptr [rbp - 0x30]
    0x10000ae09 <+73>:  mov    qword ptr [rax + 0x10], rcx
    0x10000ae0d <+77>:  mov    rcx, qword ptr [rbp - 0x38]
    0x10000ae11 <+81>:  mov    qword ptr [rax + 0x18], rcx
    0x10000ae15 <+85>:  lea    rcx, [rip + 0x94]         ; partial apply forwarder for reabstraction thunk helper from @escaping @callee_guaranteed () -> (@out Swift.Int) to @escaping @callee_guaranteed () -> (@unowned Swift.Int) at <compiler-generated>
    0x10000ae1c <+92>:  mov    qword ptr [rbp - 0x40], rax
    0x10000ae20 <+96>:  mov    rax, rcx
    0x10000ae23 <+99>:  mov    rdx, qword ptr [rbp - 0x40]
    0x10000ae27 <+103>: add    rsp, 0x38
    0x10000ae2b <+107>: pop    r13
    0x10000ae2d <+109>: pop    rbp
    0x10000ae2e <+110>: ret

(lldb) d -s 0x000000010000ae60
MixinTest`partial apply for thunk for @escaping @callee_guaranteed (@in_guaranteed TwoNumbers) -> (@out @escaping @callee_guaranteed @substituted <A> () -> (@out A) for <Int>):
    0x10000ae60 <+0>:  push   rbp
    0x10000ae61 <+1>:  mov    rbp, rsp
    0x10000ae64 <+4>:  mov    rdx, qword ptr [r13 + 0x10]
    0x10000ae68 <+8>:  mov    rcx, qword ptr [r13 + 0x18]
    0x10000ae6c <+12>: pop    rbp
    0x10000ae6d <+13>: jmp    0x10000adc0               ; reabstraction thunk helper from @escaping @callee_guaranteed (@in_guaranteed MixinTest.TwoNumbers) -> (@out @escaping @callee_guaranteed @substituted <A> () -> (@out A) for <Swift.Int>) to @escaping @callee_guaranteed (@unowned MixinTest.TwoNumbers) -> (@owned @escaping @callee_guaranteed () -> (@unowned Swift.Int)) at <compiler-generated>
    0x10000ae72 <+18>: nop    word ptr cs:[rax + rax]
    0x10000ae7c <+28>: nop    dword ptr [rax]
    

(lldb) d -n runSum
MixinTest`runSum<T>(_:):
    0x10000a920 <+0>:   push   rbp
    0x10000a921 <+1>:   mov    rbp, rsp
    0x10000a924 <+4>:   push   r13
    0x10000a926 <+6>:   sub    rsp, 0x148
    0x10000a92d <+13>:  mov    qword ptr [rbp - 0x18], 0x0
    0x10000a935 <+21>:  xorps  xmm0, xmm0
    0x10000a938 <+24>:  movaps xmmword ptr [rbp - 0x40], xmm0
    0x10000a93c <+28>:  mov    qword ptr [rbp - 0x48], 0x0
    0x10000a944 <+36>:  movaps xmmword ptr [rbp - 0x60], xmm0
    0x10000a948 <+40>:  mov    qword ptr [rbp - 0x10], rsi
    0x10000a94c <+44>:  mov    rax, qword ptr [rsi - 0x8]
    0x10000a950 <+48>:  mov    rcx, qword ptr [rax + 0x40]
    0x10000a954 <+52>:  add    rcx, 0xf
    0x10000a958 <+56>:  and    rcx, -0x10
    0x10000a95c <+60>:  mov    rdx, rsp
    0x10000a95f <+63>:  sub    rdx, rcx
    0x10000a962 <+66>:  mov    rsp, rdx
    0x10000a965 <+69>:  mov    qword ptr [rbp - 0x18], rdi
    0x10000a969 <+73>:  mov    qword ptr [rbp - 0x70], rdi
    0x10000a96d <+77>:  mov    rdi, rdx
    0x10000a970 <+80>:  mov    rcx, qword ptr [rbp - 0x70]
    0x10000a974 <+84>:  mov    qword ptr [rbp - 0x78], rsi
    0x10000a978 <+88>:  mov    rsi, rcx
    0x10000a97b <+91>:  mov    r8, qword ptr [rbp - 0x78]
    0x10000a97f <+95>:  mov    qword ptr [rbp - 0x80], rdx
    0x10000a983 <+99>:  mov    rdx, r8
    0x10000a986 <+102>: call   qword ptr [rax + 0x10]
    0x10000a989 <+105>: lea    rcx, [rbp - 0x28]
    0x10000a98d <+109>: lea    rdi, [rip + 0x64fc]       ; demangling cache variable for type metadata for (MixinTest.TwoNumbers) -> () -> Swift.Int
    0x10000a994 <+116>: mov    qword ptr [rbp - 0x88], rax
    0x10000a99b <+123>: mov    qword ptr [rbp - 0x90], rcx
    0x10000a9a2 <+130>: call   0x100007890               ; __swift_instantiateConcreteTypeFromMangledName at <compiler-generated>
    0x10000a9a7 <+135>: mov    rdi, qword ptr [rbp - 0x90]
    0x10000a9ae <+142>: mov    rsi, qword ptr [rbp - 0x80]
    0x10000a9b2 <+146>: mov    rdx, qword ptr [rbp - 0x78]
    0x10000a9b6 <+150>: mov    rcx, rax
    0x10000a9b9 <+153>: mov    r8d, 0x6
    0x10000a9bf <+159>: call   0x10000e534               ; symbol stub for: swift_dynamicCast
    0x10000a9c4 <+164>: test   al, 0x1
    0x10000a9c6 <+166>: jne    0x10000a9ca               ; <+170> at main.swift
    0x10000a9c8 <+168>: jmp    0x10000aa2f               ; <+271> at main.swift
    0x10000a9ca <+170>: lea    rax, [rip + 0x605f]       ; type metadata for MixinTest.TwoNumbers + 344
    0x10000a9d1 <+177>: add    rax, 0x10
    0x10000a9d7 <+183>: mov    rcx, qword ptr [rbp - 0x28]
    0x10000a9db <+187>: mov    rdx, qword ptr [rbp - 0x20]
    0x10000a9df <+191>: mov    rdi, rax
    0x10000a9e2 <+194>: mov    esi, 0x20
    0x10000a9e7 <+199>: mov    eax, 0x7
    0x10000a9ec <+204>: mov    qword ptr [rbp - 0x98], rdx
    0x10000a9f3 <+211>: mov    rdx, rax
    0x10000a9f6 <+214>: mov    qword ptr [rbp - 0xa0], rcx
    0x10000a9fd <+221>: call   0x10000e51c               ; symbol stub for: swift_allocObject
    0x10000aa02 <+226>: mov    rcx, qword ptr [rbp - 0xa0]
    0x10000aa09 <+233>: mov    qword ptr [rax + 0x10], rcx
    0x10000aa0d <+237>: mov    rcx, qword ptr [rbp - 0x98]
    0x10000aa14 <+244>: mov    qword ptr [rax + 0x18], rcx
    0x10000aa18 <+248>: lea    rcx, [rip + 0x441]        ; partial apply forwarder for reabstraction thunk helper from @escaping @callee_guaranteed (@in_guaranteed MixinTest.TwoNumbers) -> (@out @escaping @callee_guaranteed @substituted <A> () -> (@out A) for <Swift.Int>) to @escaping @callee_guaranteed (@unowned MixinTest.TwoNumbers) -> (@owned @escaping @callee_guaranteed () -> (@unowned Swift.Int)) at <compiler-generated>
    0x10000aa1f <+255>: mov    qword ptr [rbp - 0xa8], rcx
    0x10000aa26 <+262>: mov    qword ptr [rbp - 0xb0], rax
    0x10000aa2d <+269>: jmp    0x10000aa44               ; <+292> at main.swift
    0x10000aa2f <+271>: xor    eax, eax
    0x10000aa31 <+273>: mov    ecx, eax
    0x10000aa33 <+275>: mov    rdx, rcx
    0x10000aa36 <+278>: mov    qword ptr [rbp - 0xa8], rdx
    0x10000aa3d <+285>: mov    qword ptr [rbp - 0xb0], rcx
    0x10000aa44 <+292>: mov    rax, qword ptr [rbp - 0xb0]
    0x10000aa4b <+299>: mov    rcx, qword ptr [rbp - 0xa8]
    0x10000aa52 <+306>: cmp    rcx, 0x0
    0x10000aa56 <+310>: mov    qword ptr [rbp - 0xb8], rax
    0x10000aa5d <+317>: mov    qword ptr [rbp - 0xc0], rcx
    0x10000aa64 <+324>: je     0x10000aa84               ; <+356> at main.swift:82:30
    0x10000aa66 <+326>: mov    rax, qword ptr [rbp - 0xc0]
    0x10000aa6d <+333>: mov    rcx, qword ptr [rbp - 0xb8]
    0x10000aa74 <+340>: mov    qword ptr [rbp - 0xc8], rax
    0x10000aa7b <+347>: mov    qword ptr [rbp - 0xd0], rcx
    0x10000aa82 <+354>: jmp    0x10000aa89               ; <+361> at main.swift
    0x10000aa84 <+356>: jmp    0x10000acc0               ; <+928> at main.swift:86:1
    0x10000aa89 <+361>: mov    rax, qword ptr [rbp - 0xd0]
    0x10000aa90 <+368>: mov    rcx, qword ptr [rbp - 0xc8]
    0x10000aa97 <+375>: mov    qword ptr [rbp - 0x40], rcx
    0x10000aa9b <+379>: mov    qword ptr [rbp - 0x38], rax
    0x10000aa9f <+383>: mov    rdi, rax
    0x10000aaa2 <+386>: mov    qword ptr [rbp - 0xd8], rax
    0x10000aaa9 <+393>: mov    qword ptr [rbp - 0xe0], rcx
    0x10000aab0 <+400>: call   0x10000e576               ; symbol stub for: swift_retain
    0x10000aab5 <+405>: mov    edi, 0x2
    0x10000aaba <+410>: mov    esi, 0x3
    0x10000aabf <+415>: mov    qword ptr [rbp - 0xe8], rax
    0x10000aac6 <+422>: call   0x100008e90               ; MixinTest.TwoNumbers.init(a: Swift.Int, b: Swift.Int) -> MixinTest.TwoNumbers at TestFunctions.swift:36
    0x10000aacb <+427>: mov    rdi, rax
    0x10000aace <+430>: mov    rsi, rdx
    0x10000aad1 <+433>: mov    r13, qword ptr [rbp - 0xd8]
    0x10000aad8 <+440>: mov    rax, qword ptr [rbp - 0xe0]
    0x10000aadf <+447>: call   rax
    0x10000aae1 <+449>: mov    r13, rdx
    0x10000aae4 <+452>: mov    qword ptr [rbp - 0xf0], rdx
    0x10000aaeb <+459>: call   rax
    0x10000aaed <+461>: mov    qword ptr [rbp - 0x48], rax
    0x10000aaf1 <+465>: mov    rdi, qword ptr [rbp - 0xf0]
    0x10000aaf8 <+472>: mov    qword ptr [rbp - 0xf8], rax
    0x10000aaff <+479>: call   0x10000e570               ; symbol stub for: swift_release
    0x10000ab04 <+484>: mov    rdi, qword ptr [rbp - 0xd8]
    0x10000ab0b <+491>: call   0x10000e570               ; symbol stub for: swift_release
    0x10000ab10 <+496>: mov    rax, qword ptr [rip + 0x5641] ; (void *)0x00007fff81589a28: type metadata for Any
    0x10000ab17 <+503>: add    rax, 0x8
    0x10000ab1d <+509>: mov    edi, 0x1
    0x10000ab22 <+514>: mov    rsi, rax
    0x10000ab25 <+517>: call   0x10000e378               ; symbol stub for: Swift._allocateUninitializedArray<A>(Builtin.Word) -> (Swift.Array<A>, Builtin.RawPointer)
    0x10000ab2a <+522>: mov    edi, 0x5
    0x10000ab2f <+527>: mov    esi, 0x1
    0x10000ab34 <+532>: mov    qword ptr [rbp - 0x100], rax
    0x10000ab3b <+539>: mov    qword ptr [rbp - 0x108], rdx
    0x10000ab42 <+546>: call   0x10000e372               ; symbol stub for: Swift.DefaultStringInterpolation.init(literalCapacity: Swift.Int, interpolationCount: Swift.Int) -> Swift.DefaultStringInterpolation
    0x10000ab47 <+551>: mov    qword ptr [rbp - 0x60], rax
    0x10000ab4b <+555>: mov    qword ptr [rbp - 0x58], rdx
    0x10000ab4f <+559>: lea    rdi, [rip + 0x451c]       ; "sum: "
    0x10000ab56 <+566>: mov    esi, 0x5
    0x10000ab5b <+571>: mov    edx, 0x1
    0x10000ab60 <+576>: call   0x10000e300               ; symbol stub for: Swift.String.init(_builtinStringLiteral: Builtin.RawPointer, utf8CodeUnitCount: Builtin.Word, isASCII: Builtin.Int1) -> Swift.String
    0x10000ab65 <+581>: mov    rdi, rax
    0x10000ab68 <+584>: mov    rsi, rdx
    0x10000ab6b <+587>: lea    r13, [rbp - 0x60]
    0x10000ab6f <+591>: mov    qword ptr [rbp - 0x110], rdx
    0x10000ab76 <+598>: call   0x10000e36c               ; symbol stub for: Swift.DefaultStringInterpolation.appendLiteral(Swift.String) -> ()
    0x10000ab7b <+603>: mov    rdi, qword ptr [rbp - 0x110]
    0x10000ab82 <+610>: call   0x10000e522               ; symbol stub for: swift_bridgeObjectRelease
    0x10000ab87 <+615>: mov    rsi, qword ptr [rip + 0x551a] ; (void *)0x00007fff81581c80: type metadata for Swift.Int
    0x10000ab8e <+622>: mov    rdx, qword ptr [rip + 0x553b] ; (void *)0x00007fff81579cb0: protocol witness table for Swift.Int : Swift.CustomStringConvertible in Swift
    0x10000ab95 <+629>: mov    rax, qword ptr [rbp - 0xf8]
    0x10000ab9c <+636>: mov    qword ptr [rbp - 0x68], rax
    0x10000aba0 <+640>: lea    rcx, [rbp - 0x68]
    0x10000aba4 <+644>: mov    rdi, rcx
    0x10000aba7 <+647>: lea    r13, [rbp - 0x60]
    0x10000abab <+651>: call   0x10000e366               ; symbol stub for: Swift.DefaultStringInterpolation.appendInterpolation<A where A: Swift.CustomStringConvertible>(A) -> ()
    0x10000abb0 <+656>: xor    r8d, r8d
    0x10000abb3 <+659>: mov    esi, r8d
    0x10000abb6 <+662>: lea    rdi, [rip + 0x41bb]       ; ""
    0x10000abbd <+669>: mov    edx, 0x1
    0x10000abc2 <+674>: call   0x10000e300               ; symbol stub for: Swift.String.init(_builtinStringLiteral: Builtin.RawPointer, utf8CodeUnitCount: Builtin.Word, isASCII: Builtin.Int1) -> Swift.String
    0x10000abc7 <+679>: mov    rdi, rax
    0x10000abca <+682>: mov    rsi, rdx
    0x10000abcd <+685>: lea    r13, [rbp - 0x60]
    0x10000abd1 <+689>: mov    qword ptr [rbp - 0x118], rdx
    0x10000abd8 <+696>: call   0x10000e36c               ; symbol stub for: Swift.DefaultStringInterpolation.appendLiteral(Swift.String) -> ()
    0x10000abdd <+701>: mov    rdi, qword ptr [rbp - 0x118]
    0x10000abe4 <+708>: call   0x10000e522               ; symbol stub for: swift_bridgeObjectRelease
    0x10000abe9 <+713>: mov    rdi, qword ptr [rbp - 0x60]
    0x10000abed <+717>: mov    rax, qword ptr [rbp - 0x58]
    0x10000abf1 <+721>: mov    qword ptr [rbp - 0x120], rdi
    0x10000abf8 <+728>: mov    rdi, rax
    0x10000abfb <+731>: mov    qword ptr [rbp - 0x128], rax
    0x10000ac02 <+738>: call   0x10000e528               ; symbol stub for: swift_bridgeObjectRetain
    0x10000ac07 <+743>: lea    rdi, [rbp - 0x60]
    0x10000ac0b <+747>: mov    qword ptr [rbp - 0x130], rax
    0x10000ac12 <+754>: call   0x100007ac0               ; outlined destroy of Swift.DefaultStringInterpolation at <compiler-generated>
    0x10000ac17 <+759>: mov    rdi, qword ptr [rbp - 0x120]
    0x10000ac1e <+766>: mov    rsi, qword ptr [rbp - 0x128]
    0x10000ac25 <+773>: mov    qword ptr [rbp - 0x138], rax
    0x10000ac2c <+780>: call   0x10000e2fa               ; symbol stub for: Swift.String.init(stringInterpolation: Swift.DefaultStringInterpolation) -> Swift.String
    0x10000ac31 <+785>: mov    rcx, qword ptr [rip + 0x5448] ; (void *)0x00007fff8157fe00: type metadata for Swift.String
    0x10000ac38 <+792>: mov    rsi, qword ptr [rbp - 0x108]
    0x10000ac3f <+799>: mov    qword ptr [rsi + 0x18], rcx
    0x10000ac43 <+803>: mov    qword ptr [rsi], rax
    0x10000ac46 <+806>: mov    qword ptr [rsi + 0x8], rdx
    0x10000ac4a <+810>: call   0x100005d60               ; default argument 1 of Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () at <compiler-generated>
    0x10000ac4f <+815>: mov    qword ptr [rbp - 0x140], rax
    0x10000ac56 <+822>: mov    qword ptr [rbp - 0x148], rdx
    0x10000ac5d <+829>: call   0x100005d80               ; default argument 2 of Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () at <compiler-generated>
    0x10000ac62 <+834>: mov    rdi, qword ptr [rbp - 0x100]
    0x10000ac69 <+841>: mov    rsi, qword ptr [rbp - 0x140]
    0x10000ac70 <+848>: mov    rcx, qword ptr [rbp - 0x148]
    0x10000ac77 <+855>: mov    qword ptr [rbp - 0x150], rdx
    0x10000ac7e <+862>: mov    rdx, rcx
    0x10000ac81 <+865>: mov    rcx, rax
    0x10000ac84 <+868>: mov    r8, qword ptr [rbp - 0x150]
    0x10000ac8b <+875>: call   0x10000e396               ; symbol stub for: Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> ()
    0x10000ac90 <+880>: mov    rdi, qword ptr [rbp - 0x150]
    0x10000ac97 <+887>: call   0x10000e522               ; symbol stub for: swift_bridgeObjectRelease
    0x10000ac9c <+892>: mov    rdi, qword ptr [rbp - 0x148]
    0x10000aca3 <+899>: call   0x10000e522               ; symbol stub for: swift_bridgeObjectRelease
    0x10000aca8 <+904>: mov    rdi, qword ptr [rbp - 0x100]
    0x10000acaf <+911>: call   0x10000e522               ; symbol stub for: swift_bridgeObjectRelease
    0x10000acb4 <+916>: mov    rdi, qword ptr [rbp - 0xd8]
    0x10000acbb <+923>: call   0x10000e570               ; symbol stub for: swift_release
    0x10000acc0 <+928>: lea    rsp, [rbp - 0x8]
    0x10000acc4 <+932>: pop    r13
    0x10000acc6 <+934>: pop    rbp
    0x10000acc7 <+935>: ret    

(lldb) 



# Class methods

[r13 + 0x18] + 0x18 is the address of the allocated class.
[[class address] + 0xb8]

dynamic methods don't work because of ARC getting messed up by starting halfway through, it's easier just to use the disassembler to find the result of the lea that loads the partial apply forwarder 

The first of these nested implicit closures is for a method on the class. The second is for a method from an extension of the class.

```
(lldb) d -a 0x10000c4f0
MixinTest`implicit closure #2 in implicit closure #1 in main():
    0x10000c4f0 <+0>:  push   rbp
    0x10000c4f1 <+1>:  mov    rbp, rsp
    0x10000c4f4 <+4>:  push   r13
    0x10000c4f6 <+6>:  push   rax
    0x10000c4f7 <+7>:  mov    qword ptr [rbp - 0x10], 0x0
    0x10000c4ff <+15>: mov    qword ptr [rbp - 0x10], rdi
    0x10000c503 <+19>: mov    rax, qword ptr [rdi]
    0x10000c506 <+22>: mov    rax, qword ptr [rax + 0xb8]
    0x10000c50d <+29>: mov    r13, rdi
    0x10000c510 <+32>: call   rax
    0x10000c512 <+34>: add    rsp, 0x8
    0x10000c516 <+38>: pop    r13
    0x10000c518 <+40>: pop    rbp
    0x10000c519 <+41>: ret    

(lldb) d -a 0x10000c670
MixinTest`implicit closure #4 in implicit closure #3 in main():
    0x10000c670 <+0>:  push   rbp
    0x10000c671 <+1>:  mov    rbp, rsp
    0x10000c674 <+4>:  push   r13
    0x10000c676 <+6>:  push   rax
    0x10000c677 <+7>:  mov    qword ptr [rbp - 0x10], 0x0
    0x10000c67f <+15>: mov    qword ptr [rbp - 0x10], rdi
    0x10000c683 <+19>: mov    r13, rdi
    0x10000c686 <+22>: call   0x10000b5c0               ; MixinTest.ThreeNumbers.product() -> Swift.Int at main.swift:59
    0x10000c68b <+27>: add    rsp, 0x8
    0x10000c68f <+31>: pop    r13
    0x10000c691 <+33>: pop    rbp
    0x10000c692 <+34>: ret
```

# Static struct methods

call [[r13 + 0x18] + 0x10]