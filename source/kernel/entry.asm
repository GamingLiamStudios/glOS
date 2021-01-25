section .text
[bits 64]
[extern _kernel]
global _enter_kernel ; So link.ld can find the entry-point

_enter_kernel:
    call _kernel

    jmp $

%include "source/kernel/interrupts/idt.asm"
