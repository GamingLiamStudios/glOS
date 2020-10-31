#include "drivers/display.h"

void _kernel() {
    clear();                  // Works fine
    *((char*)0xb8000) = 'X';  // Bootloop
}
