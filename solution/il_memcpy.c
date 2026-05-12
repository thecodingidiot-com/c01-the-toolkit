#include "idiotlib.h"

void    *il_memcpy(void *dst, const void *src, size_t n)
{
    unsigned char       *d;
    const unsigned char *s;

    d = (unsigned char *)dst;
    s = (const unsigned char *)src;
    while (n--)
        *d++ = *s++;
    return (dst);
}
