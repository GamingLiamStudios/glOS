#pragma once
#ifndef MEMH
#define MEMH
// https://quick-bench.com/q/A9nIt8KHyL3h5TkHIWSvjjJbMes
void memcpy(void *dest, void *src, int n) {
    int mod = n % 4;
    __asm__ __volatile__("cld; rep movsd;"
                         :
                         : "c"((n - mod) / 4), "S"(src), "D"(dest));
    while (mod--) *((char *)dest + n - mod - 1) = *((char *)src + n - mod - 1);
}
#endif