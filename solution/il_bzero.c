#include "idiotlib.h"

void    il_bzero(void *s, size_t n)
{
    unsigned char   *p;

    p = (unsigned char *)s;
    while (n--)
        *p++ = 0;
}
