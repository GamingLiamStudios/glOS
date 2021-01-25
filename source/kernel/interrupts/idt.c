#include "idt.h"

#include "drivers/display.h"
#include "kernel/io.h"

void initIDT()
{
    printf("Initalizing IDT\n");
    for (u64 t = 0; t < 256; t++)
    {
        _idt[t].offset_1  = (u16)((u64) &isr1 & 0xffff);
        _idt[t].selector  = 0x08;
        _idt[t].ist       = 0;
        _idt[t].type_attr = IDT_TA_unused;
        _idt[t].offset_2  = (u16)(((u64) &isr1 >> 16) & 0xffff);
        _idt[t].offset_3  = (u32)(((u64) &isr1 >> 32) & 0xffffffff);
        _idt[t].zero      = 0;
    }

    _idt[1].type_attr = IDT_TA_interrupt;

    // Tell CPU where IDT is
    idtr = (IDTR) { .offset = (u64) &_idt, .limit = sizeof(_idt) - 1 };
    __asm__("lidt %0" : : "m"(idtr));

    poutb(PIC1_DATA, 0xfd);
    poutb(PIC2_DATA, 0xff);

    __asm__("sti");

    printf("%i\n", &idtr);
}

void _isr1_handler()
{
    printf("%d\n", pinb(0x60));
    poutb(PIC2_COMMAND, 0x20);
    poutb(PIC1_COMMAND, 0x20);
}