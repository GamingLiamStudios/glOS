#pragma once
#ifndef MEMH
#define MEMH
// https://quick-bench.com/q/A9nIt8KHyL3h5TkHIWSvjjJbMes
void memcpy(void *to, void *from, int count) {
    int mod = count % 4;
    __asm__ __volatile__("cld; rep movsd;"
                         :
                         : "c"((count - mod) / 4), "S"(from), "D"(to));
    while (mod--)
        *((char *)to + count - mod - 1) = *((char *)from + count - mod - 1);
}
#endif