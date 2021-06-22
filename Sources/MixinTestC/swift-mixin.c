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
 movabs rax, TEMPLATE
 jmp rax
 */
#define THUNK_TEMPLATE "\x48\xb8""TEMPLATE""\xff\xe0" // TODO: make payload smaller

char * jump_thunk_template = THUNK_TEMPLATE;
size_t thunk_size = sizeof(THUNK_TEMPLATE) - 1;
unsigned long thunk_stride = ((sizeof(THUNK_TEMPLATE) - 2) | 15) + 1;

// Private functions
int make_page_rwx_at_address(void *);
int make_page_rx_at_address(void *);

/// Overwrites the function pointed to by the first argument.
int overwrite_function(unsigned long function_to_replace, unsigned long replacement) {
  int page_size = getpagesize();
  void *page_aligned = (void *)(function_to_replace & ~(page_size-1));
  
  // Add write permissions to the memory page contains the start of the function
  if (make_page_rwx_at_address(page_aligned) == -1) {
    return -1;
  }
  
  // Add write permissions to the next memory page as well if necessary to fit the thunk
  int has_unlocked_second_page = 0;
  if (function_to_replace + thunk_stride >= (unsigned long)page_aligned + page_size) {
    if (make_page_rwx_at_address(page_aligned+page_size) == -1) {
      return -1;
    }
    has_unlocked_second_page = 1;
  }
  
  // Overwrite the start of the function with the thunk template
  memcpy((void *)function_to_replace, (void *)jump_thunk_template, thunk_size);
  
  // Write the replacement function's address to the correct spot in the template
  *(long *)((char*)function_to_replace + 2) = replacement;
  
  // Remove write permissions again
  if (make_page_rx_at_address(page_aligned) == -1) {
    return -2;
  }
  
  // Remove write permissions from second page if necessary
  if (has_unlocked_second_page) {
    if (make_page_rx_at_address(page_aligned+page_size) == -1) {
      return -2;
    }
  }
  
  // TODO: handle function being too small
  
  return 0;
}

/// Makes a memory page rwx
int make_page_rwx_at_address(void *addr) {
  int page_size = getpagesize();
  addr -= (unsigned long)addr % page_size;
  
  if (mprotect(addr, page_size, PROT_READ | PROT_WRITE | PROT_EXEC) < 0) {
    perror("mprotect"); return -1;
  }
  
  return 0;
}

/// Makes a memory page r-x
int make_page_rx_at_address(void *addr) {
  int page_size = getpagesize();
  addr -= (unsigned long)addr % page_size;
  
  if (mprotect(addr, page_size, PROT_READ | PROT_EXEC) < 0) {
    perror("mprotect"); return -1;
  }
  
  return 0;
}

unsigned long run_void_to_uint64_thunk(unsigned long addr) {
  unsigned long (*thunk)() = addr;
  unsigned long result = thunk();
  return result;
}
