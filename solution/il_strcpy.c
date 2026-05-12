#include "idiotlib.h"

char    *il_strcpy(char *dst, const char *src)
{
    char    *start;

    start = dst;    /* return start so callers can chain: strcpy(dst, src)[0] etc. */
    while ((*dst++ = *src++))  /* assignment inside condition: copies the byte and tests it in one expression */
        ;
    return (start);
}
