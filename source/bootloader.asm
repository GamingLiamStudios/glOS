[BITS 16]
[ORG 0x7C00]

mov si, STRING

print:
mov al, [si]
call print_char
inc si
or al, al
jnz print

jmp $

print_char:
mov ah, 0x0E
int 0x10
ret

.DATA
STRING db 'Hello World!' , 0

TIMES 510 - ($ - $$) db 0
DW 0xAA55