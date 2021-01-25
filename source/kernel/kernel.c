#include "drivers/display.h"
#include "kernel/IDT/idt.h"

void _kernel()
{
    initIDT();
    printf("Hello World!\n");
    printf(
      "Isn't it lovely to have printf working?\nIts nice for me, at "
      "least.\n");
}
