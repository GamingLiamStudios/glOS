#pragma once
#ifndef IDTH
#define IDTH

#include "kernel/typedef.h"

// TODO: Other Compiler support

typedef struct __attribute__((packed)) {
    u16 offset_low;
    u16 selector;
    u8 zero1;
    u8 types_attr;
    u16 offset_mid;
    u32 offset_hi;
    u32 zero2;
} IDT64;

typedef struct __attribute__((packed)) {
    u16 limit;
    u64 offset;
} IDT_DESCRIPTOR;

extern IDT64 _idt[256];
extern u64 isr1;

void initIDT();
void _isr1_handler();

#endif
