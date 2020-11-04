#include "kernel/IDT/idt.h"

#include "drivers/display.h"
#include "kernel/io.h"

void initIDT() {
    for (u64 t = 0; t < 256; t++) {
        _idt[t].zero = 0;
        _idt[t].offset_low = (u16)(((u64)&isr1 & 0x000000000000ffff));
        _idt[t].offset_mid = (u16)(((u64)&isr1 & 0x00000000ffff0000) >> 16);
        _idt[t].offset_hi = (u32)(((u64)&isr1 & 0xffffffff00000000) >> 32);
        _idt[t].ist = 0;
        _idt[t].selector = 0x08;
        _idt[t].types_attr = 0x8e;
    }

    poutb(0x21, 0xfd);
    poutb(0xa1, 0xff);
    loadIDT();
}

void _isr1_handler() {
    printf("%d\n", pinb(0x60));
    poutb(0x20, 0x20);
    poutb(0xa0, 0x20);
}