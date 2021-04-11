#pragma once
// https://quick-bench.com/q/A9nIt8KHyL3h5TkHIWSvjjJbMes
// https://quick-bench.com/q/vKWM8x5rqo2rCdzCfa73Al59F3k
void memcpy(volatile void *_dest, volatile void *_src, int _n)
{
    int mod = _n % 4;
    __asm__ __volatile__("cld; rep movsd;" : : "c"((_n - mod) / 4), "S"(_src), "D"(_dest));
    while (mod--) *((char *) _dest + _n - mod - 1) = *((char *) _src + _n - mod - 1);
}
