#include "drivers/display.h"

void _kernel() {
    clear();
    printf("Hello World!\n");
    printf(
        "Isn't it lovely to have printf working?\nIts nice for me, at "
        "least.\n");
}
