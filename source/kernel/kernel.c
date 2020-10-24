void _start_kernel() {
    int* graphics_ptr = (int*)0xb8000;
    for (int i = 0; i < 1000; i++) *(graphics_ptr++) = 0x50505050;
    return;
}