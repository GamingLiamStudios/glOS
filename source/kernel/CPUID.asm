[bits 32]

detect_cpuid:
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
    jz .nocpuid
    ret
    .nocpuid:
    hlt ; No CPUID support. Error message?

detect_lm:
    mov eax, 0x80000001
    cpuid
    test edx, 1 << 29
    jz .nolm
    ret
    .nolm:
    hlt ; 32-bit support?