#include "idiotlib.h"

char    *il_strncpy(char *dst, const char *src, size_t n)
{
    size_t  i;

    i = 0;
    while (i < n && src[i]) {
        dst[i] = src[i];
        i++;
    }
    /* pad remaining bytes with '\0' as strncpy specifies */
    while (i < n)
        dst[i++] = '\0';
    return (dst);
}
