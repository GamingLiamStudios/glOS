; Stuff for GDT
gdt_nulldesc:
    dd 0
    dd 0

gdt_codedesc:
    dw 0xFFFF ; Limit
    dw 0x0000 ; Base(Low)
    db 0x00 ; Base(Medium)
    db 10011010b ; Access Byte 
    db 11001111b ; Flags | Upper Limit
    db 0x00 ; Base(High)

gdt_datadesc:
    dw 0xFFFF ; Limit
    dw 0x0000 ; Base(Low)
    db 0x00 ; Base(Medium)
    db 10010010b ; Access Byte 
    db 11001111b ; Flags | Upper Limit
    db 0x00 ; Base(High)

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_nulldesc - 1
    dq gdt_nulldesc

codeseg equ gdt_codedesc - gdt_nulldesc
dataseg equ gdt_datadesc - gdt_nulldesc 