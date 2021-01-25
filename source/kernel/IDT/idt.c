#include "kernel/IDT/idt.h"

#include "drivers/display.h"
#include "kernel/io.h"

extern void idt_load(IDT_DESCRIPTOR *);

void initIDT() {
    printf("Initalizing IDT\n");
    for (u64 t = 0; t < 256; t++) {
        _idt[t].offset_low = (u16)((u64)&isr1 & 0xFFFF);
        _idt[t].selector = 0x08;
        _idt[t].zero1 = 0;
        _idt[t].types_attr = 0b00101110;
        _idt[t].offset_mid = (u16)(((u64)&isr1 >> 16) & 0xFFFF);
        _idt[t].offset_hi = (u32)(((u64)&isr1 >> 32) & 0xFFFFFFFF);
        _idt[t].zero2 = 0;
    }

    _idt[1].types_attr |= 0x80;

    // Tell CPU where IDT is
    IDT_DESCRIPTOR idt_desc = {.offset = (u64)&_idt, .limit = sizeof(_idt) - 1};
    idt_load(&idt_desc);

    printf("%i\n", &idt_desc);
}

void _isr1_handler() {
    printf("%d\n", pinb(0x60));
    poutb(PIC2_COMMAND, 0x20);
    poutb(PIC1_COMMAND, 0x20);
}