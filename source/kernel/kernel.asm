[bits 32]
_init_kernel:
    mov ebx, STRING
    call print

    ; Check for 64-bit Long mode compat
    call detect_cpuid
    call detect_lm
    call setup_paging_id
    call edit_gdt

    jmp codeseg:_init_kernel_64

    jmp $

%include "bootloader/gdt.asm"
%include "kernel/CPUID.asm"
%include "kernel/identity_paging.asm"

print:
    pusha
    mov edx, 0xb8000
    .loop:
        mov al, [ebx]
        mov ah, 0x0f
        cmp al, 0
        je .end
        mov [edx], ax
        add ebx, 1
        add edx, 2
        jmp .loop
    .end:
    popa
    ret

STRING:
    db '32-bit mode! :D' , 0

[bits 64]
[extern _start_kernel]

_init_kernel_64:
    mov edi, 0xb8000
    mov eax, 0x1f201f20
    mov ecx, 1000
    rep stosd

    call _start_kernel

    jmp $

times 2048 - ($ - $$) db 0 ; Fill rest of next 4 sectors