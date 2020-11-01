#pragma once
#ifndef IDTH
#define IDTH
#include "typedef.h"
struct IDT64 {
    u16 offset_lo;
    u16 selector;
    u8 ist;
    u8 types_attr;
    u16 offset_mid;
    u16 offset_hi;
    u32 zero;
};

struct IDT64 _idt[256];

void initIDT();
#endif
