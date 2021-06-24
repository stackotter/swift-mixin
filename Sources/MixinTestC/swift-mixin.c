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
unsigned long thunk_stride = ((sizeof(THUNK_TEMPLATE) - 1) | 7) + 1;

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
  
  // Write the replacement function's offset to the correct spot in the template
  unsigned long offset = replacement - (function_to_replace + thunk_size);
  *(int *)((char*)function_to_replace + 1) = offset;
  
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

/// Returns the result of a () -> UInt function located at `addr`
unsigned long run_void_to_uint64_function(unsigned long addr) {
  unsigned long (*thunk)() = addr;
  unsigned long result = thunk();
  return result;
}

/**
 Returns the length of the function at the given address in bytes.
 
 It iteratively searches the function for the return instruction. This method relies
 on there only being one return instruction which I think is always true.
 */
//int get_function_length(unsigned long addr) {
//  int i = 0, count = 0;
//  char disassembled[0xff];
//  while(1) {
//    if (*(unsigned char *)(addr + i) == 0xc3) {
//      break;
//    }
//
//    count = disassemble((unsigned char *)(addr + i), 100, i, disassembled);
//    i += count;
//  }
//  return i + 1;
//}

int set_mem_prot(unsigned long addr, unsigned long length, int prot) {
  int page_size = getpagesize();
  unsigned long page_aligned = addr & ~(page_size-1);
  int num_pages = (addr - page_aligned) / page_size + 1;
  mprotect((void *)page_aligned, page_size * num_pages, prot);
}
//
///// Effectively duplicates a function and returns the address of the duplicate.
//unsigned long duplicate_function(unsigned long addr) {
//  int length = get_function_length(addr);
//
//  char disassembled[0xff];
//  int i = 0;
//  while(i < thunk_size) {
//    int count = disassemble((unsigned char *)(addr + i), 100, i, disassembled);
//    printf("count: %d, disas: %s\n", i, disassembled);
//    i += count;
//  }
//
//  int num_bytes_to_copy = i;
//  printf("num bytes to copy: %d\n", num_bytes_to_copy);
//  void * function = (void *)addr;
//  void * copy = malloc(num_bytes_to_copy + thunk_size);
//  memcpy(copy, function, num_bytes_to_copy);
//  int offset = (int)((unsigned long)function - ((unsigned long)copy + num_bytes_to_copy + thunk_size));
//  printf("offset: %d\n", offset);
//  memcpy((void *)((char *)copy + num_bytes_to_copy), jump_thunk_template, thunk_size);
//  *(int *)((char *)copy + num_bytes_to_copy + thunk_size + 1) = offset;
//
//  set_mem_prot((unsigned long)copy, length, PROT_READ | PROT_EXEC | PROT_WRITE);
//  return (unsigned long)copy;
//}
