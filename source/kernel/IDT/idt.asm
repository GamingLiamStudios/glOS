%macro PUSHALL 0
    push rax
    push rcx
    push rdx
    push r8
    push r9
    push r10
    push r11
%endmacro

%macro POPALL 0
    pop r11
    pop r10
    pop r9
    pop r8
    pop rdx
    pop rcx
    pop rax
%endmacro

idt_load:
	lidt [rdi]

    ; Enable only the keyboard
    mov al, 0xfd
    out 0x21, al
    mov al, 0xff
    out 0xa1, al

    sti
	ret
    global idt_load

[extern _isr1_handler]
isr1:
    hlt
    PUSHALL
    cld
    call _isr1_handler
    POPALL
    iretq
    global isr1
    