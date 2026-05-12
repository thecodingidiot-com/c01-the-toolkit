#include "idiotlib.h"

char    *il_strcpy(char *dst, const char *src)
{
    char    *start;

    start = dst;
    while ((*dst++ = *src++))
        ;
    return (start);
}
