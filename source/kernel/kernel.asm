[org 0x7e00]
_entry_point:
    mov si, STRING
    call print
    ret

%include "source/bootloader/io.asm"

STRING:
    db 'Ello from extended space!' , 0

times 2048 - ($ - $$) db 0 ; Fill rest of next 4 sectors