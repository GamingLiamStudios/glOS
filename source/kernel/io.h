#pragma once
#ifndef PORTIO
#define PORTIO
inline unsigned char pinb(unsigned short port) {
    unsigned char result;
    __asm__ __volatile__("inb %1, %0" : "=a"(result) : "Nd"(port));
    return result;
}
inline unsigned short pinw(unsigned short port) {
    unsigned short result;
    __asm__ __volatile__("inw %1, %0" : "=a"(result) : "Nd"(port));
    return result;
}
inline void poutb(unsigned short port, unsigned char data) {
    __asm__ __volatile__("outb %0, %1" : : "a"(data), "Nd"(port));
}
inline void poutw(unsigned short port, unsigned short data) {
    __asm__ __volatile__("outw %0, %1" : : "a"(data), "Nd"(port));
}
#endif