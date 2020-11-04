#include "display.h"

#include <stdarg.h>  // Vardaic Arguements

#include "kernel/io.h"
#include "kernel/memory.h"

uint16_t cursor_get() {
    poutb(REG_SCREEN_CTRL, 14);
    uint16_t offset = pinb(REG_SCREEN_DATA) << 8;
    poutb(REG_SCREEN_CTRL, 15);
    offset += pinb(REG_SCREEN_DATA);
    return offset;
}

void cursor_set(short pos) {
    poutb(0x3d4, 0x0f);
    poutb(0x3d5, (char)(pos & 0xFF));
    poutb(0x3d4, 0x0e);
    poutb(0x3d5, (char)((pos >> 8) & 0xFF));
}

void clear() {
    __asm__("cld; rep stosl;" : : "c"(1000), "a"(CLEAR_COLOR), "D"(VGA_MEMORY));
    cursor_set(0);
}

void sprint(sprint_args in) {
    uint16_t offset = cursor_get();  // Current Offset
    char c = in.c ? in.c : ' ';
    char a =
        in.a ? in.a : offset ? *((char *)VGA_MEMORY + offset * 2 - 1) : 0x1f;

    switch (c) {
        case '\n': {
            offset += VGA_COLS - (offset % VGA_COLS) - 1;
            break;
        }
        default: {
            *((char *)VGA_MEMORY + offset * 2) = c;
            *((char *)VGA_MEMORY + offset * 2 + 1) = a;
            break;
        }
    }
    offset++;

    if (offset >= VGA_COLS * VGA_ROWS) {
        // Screen scrolling
        memcpy((char *)VGA_MEMORY, (char *)VGA_MEMORY + (VGA_COLS * 2),
               (VGA_COLS * VGA_ROWS * 2) - (VGA_COLS * 2));
        __asm__("cld; rep stosl;"
                :
                : "c"((VGA_COLS * 2) / 4), "a"(CLEAR_COLOR),
                  "D"(VGA_MEMORY + (VGA_COLS * VGA_ROWS * 2) - (VGA_COLS * 2)));
        offset -= VGA_COLS;
    }

    cursor_set(offset);
}

void printf(const char *msg, ...) {
    va_list fmt;
    va_start(fmt, msg);

    char *str = msg - 1;
    while (*++str != '\0') {
        if (*str == '%') {
            // Formatting
            char c;
            while (1) switch (*++str) {
                    case 'd':
                    case 'i': {
                        uint32_t bin = va_arg(fmt, int);

                        uint8_t size = 0;
                        uint32_t size_tester = bin;
                        while ((size_tester /= 10) > 0) size++;

                        uint8_t index = 0;

                        if (bin < 0) {
                            index++;
                            size++;
                            *format_buf = '-';
                            bin = ~bin & 0x7FFFFFFF;
                        }

                        size_tester = bin;
                        while (size_tester / 10 > 0) {
                            uint8_t remainder = size_tester % 10;
                            size_tester /= 10;
                            format_buf[size - index++] = remainder + 48;
                        }
                        uint8_t remainder = size_tester % 10;
                        format_buf[size - index] = remainder + 48;
                        format_buf[size + 1] = 0;

                        printf(format_buf);  // Print Recently decoded text
                    } break;
                }
        } else  // TODO: ANSI Escape Codes
            printc(*str);
    }

    va_end(fmt);
}