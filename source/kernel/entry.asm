[bits 32]
_detect_64:
    ; Detect CPUID
    pushfd
    pop eax
    mov ecx, eax
    xor eax, 1 << 21
    push eax
    popfd

    pushfd
    pop eax
    push ecx
    popfd

    xor eax, ecx
    jnz .detect_lm ; Detect long mode if CPUID is supported

    ; Print error message
    mov esi, cpuid_err
    mov cx, 19
    mov edi, 0xb8000
    cld
    rep movsw
    hlt

    .detect_lm:
    mov eax, 0x80000000
    cpuid
    cmp eax, 0x80000001
    jb .no_lm

    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jnz _enter_lm

    .no_lm
    ; Print error message
    mov esi, cpuid_err
    mov cx, 19
    mov edi, 0xb8000
    cld
    rep movsw
    hlt ; TODO: 32-bit Support

_enter_lm:
    call id_paging_setup ; Fails Here

    ; Edit GDT for 64-bit usage
    mov byte [gdt_codedesc + 6], 10101111b
    mov byte [gdt_datadesc + 6], 10101111b

    jmp codeseg:enter_kernel

    jmp $

%include "source/boot/gdt.asm"
%include "source/kernel/id_paging.asm"

cpuid_err: ; 'CPUID not Supported'
    dw 0x0f43, 0x0f50, 0x0f55, 0x0f49, 0x0f44, 0x0f20, 0x0f6e, 0x0f6f, 0x0f74, 0x0f20, 0x0f53, 0x0f75, 0x0f70, 0x0f70, 0x0f6f, 0x0f72, 0x0f74, 0x0f65, 0x0f64

lm_err: ; 64bit not Supported
    dw 0x0f36, 0x0f34, 0x0f62, 0x0f69, 0x0f74, 0x0f20, 0x0f6e, 0x0f6f, 0x0f74, 0x0f20, 0x0f53, 0x0f75, 0x0f70, 0x0f70, 0x0f6f, 0x0f72, 0x0f74, 0x0f65, 0x0f64
 
[bits 64]
[extern kernel]

enter_kernel:
    call kernel

    jmp $