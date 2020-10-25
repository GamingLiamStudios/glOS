unsigned char port_in(unsigned short port) {
    unsigned char result;
    __asm__("in %%dx, %%al" : "=a"(result) : "d"(port));
    return result;
}
unsigned short port_inw(unsigned short port) {
    unsigned short result;
    __asm__("in %%dx, %%ax" : "=a"(result) : "d"(port));
    return result;
}
void port_out(unsigned short port, unsigned char data) {
    __asm__("out %%al, %%dx" : : "a"(data), "d"(port));
}
void port_outw(unsigned short port, unsigned short data) {
    __asm__("out %%ax, %%dx" : : "a"(data), "d"(port));
}

#define VIDEO_ADDRESS 0xb8000