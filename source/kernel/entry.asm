section .text
[bits 32]
global _enter_lm ; So link.ld can find the entry-point
_enter_lm:
    ; Check if Extended Functions exist
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb no_lm

    ; Check for Long Mode
    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz no_lm

    call id_paging_setup

    ; Edit GDT for 64-bit usage
    mov [gdt_codedesc + 6], byte 10101111b
    mov [gdt_datadesc + 6], byte 10101111b

    jmp codeseg:enter_kernel

    jmp $

no_lm:
    ; Print error message
    mov esi, lm_err
    mov cx, 19
    mov edi, 0xb8000
    cld
    rep movsw
    hlt ; TODO: 32-bit Support

%include "source/boot/gdt.asm"
%include "source/kernel/id_paging.asm"

[bits 64]
[extern _kernel]

enter_kernel:
    call _kernel

    jmp $

section .rodata
lm_err: ; 64bit not Supported
    dw 0x1f36, 0x1f34, 0x1f62, 0x1f69, 0x1f74, 0x1f20, 0x1f6e, 0x1f6f, 0x1f74, 0x1f20, 0x1f53, 0x1f75, 0x1f70, 0x1f70, 0x1f6f, 0x1f72, 0x1f74, 0x1f65, 0x1f64