#include "idiotlib.h"

void    *il_memmove(void *dst, const void *src, size_t n)
{
    unsigned char       *d;
    const unsigned char *s;

    d = (unsigned char *)dst;
    s = (const unsigned char *)src;
    if (d > s && d < s + n) {
        /* regions overlap and dst is ahead: copy backwards to avoid clobbering src */
        d += n;
        s += n;
        while (n--)
            *--d = *--s;
    } else {
        while (n--)
            *d++ = *s++;
    }
    return (dst);
}
