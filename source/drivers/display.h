#pragma once
#include "kernel/typedef.h"

#define VGA_MEMORY  0xb8000
#define VGA_ROWS    25
#define VGA_COLS    80
#define CLEAR_COLOR 0x1f201f20
// TODO: Detect screen size

#define REG_SCREEN_CTRL 0x3D4
#define REG_SCREEN_DATA 0x3D5

// Display functions
u16  cursor_get();
void cursor_set(short pos);
void clear();

static char format_buf[128];

// Character printing functions
struct sprint_args
{
    char c;
    char a;
};
void sprint(struct sprint_args in);    // Print char to screen
#define printc(...) sprint((struct sprint_args) { __VA_ARGS__ });
void printf(const char *str, ...);
