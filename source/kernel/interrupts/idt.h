#pragma once
#ifndef IDTH
#define IDTH

#include "kernel/typedef.h"

#define IDT_TA_unused    0b00001110
#define IDT_TA_interrupt 0b10001110
#define IDT_TA_call      0b10001100
#define IDT_TA_trap      0b10001111

typedef struct
{
    u16 offset_1;
    u16 selector;
    u8  ist;
    u8  type_attr;
    u16 offset_2;
    u32 offset_3;
    u32 zero;
} IDT64;

// TODO: Other Compiler support
typedef struct __attribute__((packed))
{
    u16 limit;
    u64 offset;
} IDTR;

extern IDT64 _idt[256];
extern u64   isr1;

static IDTR idtr;

void initIDT();
void _isr1_handler();

#endif
