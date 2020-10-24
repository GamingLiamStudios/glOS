[bits 32]
[org 0x7e00]
kernel:
    mov ebx, STRING
    call print

    jmp $

print:
    pusha
    mov edx, 0xb8000
    .loop:
        mov al, [ebx]
        mov ah, 0x0f
        cmp al, 0
        je .end
        mov [edx] , ax
        add ebx , 1
        add edx , 2
        jmp .loop
    .end:
    popa
    ret

STRING:
    db '32-bit mode! :D' , 0

times 2048 - ($ - $$) db 0 ; Fill rest of next 4 sectors