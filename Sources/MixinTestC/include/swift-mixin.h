//
//  swift-mixin.h
//  MixinTest
//
//  Created by Rohan van Klinken on 21/6/21.
//

#ifndef swift_mixin_h
#define swift_mixin_h

int overwrite_function(unsigned long function, unsigned long replacement);
int get_function_length(unsigned long addr);
unsigned long duplicate_function(unsigned long addr);

unsigned long run_void_to_uint64_function(unsigned long addr);

#endif /* swift_mixin_h */
