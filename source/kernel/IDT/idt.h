#pragma once
#ifndef IDTH
#define IDTH
#include "kernel/typedef.h"
struct IDT64 {
    u16 offset_low;
    u16 selector;
    u8 ist;
    u8 types_attr;
    u16 offset_mid;
    u32 offset_hi;
    u32 zero;
};

extern struct IDT64 _idt[256];
extern u64 isr1;
extern void loadIDT();

void initIDT();
void _isr1_handler();
#endif
