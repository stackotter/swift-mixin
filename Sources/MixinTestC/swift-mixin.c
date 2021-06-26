//
//  swift-mixin.c
//  MixinTest
//
//  Created by Rohan van Klinken on 21/6/21.
//

#include "swift-mixin.h"

#include <stdio.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stdlib.h>
#include <memory.h>
#include <errno.h>

/*
 jmp ADDR ; addr is a 32-bit offset relative to the next instruction
 */
#define THUNK_TEMPLATE "\xe9""ADDR"

char * jump_thunk_template = THUNK_TEMPLATE;
size_t thunk_size = sizeof(THUNK_TEMPLATE) - 1;

/// Overwrites the function pointed to by the first argument.
int overwrite_function(unsigned long function_to_replace, unsigned long replacement) {
  // Add write permissions to the memory we need to write the thunk to
  set_mem_prot(function_to_replace, thunk_size, PROT_READ | PROT_WRITE | PROT_EXEC);
  
  // Overwrite the start of the function with the thunk template
  memcpy((void *)function_to_replace, (void *)jump_thunk_template, thunk_size);
  
  // Write the replacement function's offset to the correct spot in the template
  unsigned long offset = replacement - (function_to_replace + thunk_size);
  *(int *)((char*)function_to_replace + 1) = offset;
  
  // Remove write permissions again
  set_mem_prot(function_to_replace, thunk_size, PROT_READ | PROT_EXEC);
  
  return 0;
}

/// Creates a duplicate of a function only copying as much as needed to be correct after the thunk.
unsigned long duplicate_function(unsigned long addr, unsigned long num_bytes_to_copy) {
  // Copy the first few instructions that need to be saved
  void * function = (void *)addr;
  void * copy = malloc(num_bytes_to_copy + thunk_size);
  memcpy(copy, function, (int)num_bytes_to_copy);
  
  // Install a jump back to the original after the thunk
  unsigned long jump_dst = addr + num_bytes_to_copy;
  unsigned long jump_src = (unsigned long)copy + num_bytes_to_copy + thunk_size;
  int offset = (int)(jump_dst - jump_src);
  memcpy((void *)((char *)copy + num_bytes_to_copy), jump_thunk_template, thunk_size);
  *(int *)((char *)copy + num_bytes_to_copy + 1) = offset;

  // Add execute permissions to the copy
  set_mem_prot((unsigned long)copy, num_bytes_to_copy + thunk_size, PROT_READ | PROT_EXEC | PROT_WRITE);
  return (unsigned long)copy;
}

/// Sets the protection of the memory in the specified range to the specified protection level.
int set_mem_prot(unsigned long addr, unsigned long length, int prot) {
  int page_size = getpagesize();
  unsigned long page_aligned = addr & ~(page_size-1);
  int num_pages = (addr - page_aligned) / page_size + 1;
  mprotect((void *)page_aligned, page_size * num_pages, prot);
}

/// Returns the result of a () -> UInt function located at `addr`.
unsigned long run_void_to_uint64_function(unsigned long addr) {
  unsigned long (*thunk)() = addr;
  unsigned long result = thunk();
  return result;
}
