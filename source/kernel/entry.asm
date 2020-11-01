section .text
[bits 32]
global _enter_lm
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
    mov byte [gdt_codedesc + 6], 10101111b
    mov byte [gdt_datadesc + 6], 10101111b
    lgdt [gdt_descriptor]

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
    ; Init
    mov ax, dataseg
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    call _kernel

    jmp $

section .rodata
lm_err: ; 64bit not Supported
    dw 0x0f36, 0x0f34, 0x0f62, 0x0f69, 0x0f74, 0x0f20, 0x0f6e, 0x0f6f, 0x0f74, 0x0f20, 0x0f53, 0x0f75, 0x0f70, 0x0f70, 0x0f6f, 0x0f72, 0x0f74, 0x0f65, 0x0f64