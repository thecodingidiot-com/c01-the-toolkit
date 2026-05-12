#include "idiotlib.h"

size_t  il_strlcpy(char *dst, const char *src, size_t size)
{
    size_t  src_len;
    size_t  i;

    src_len = il_strlen(src);
    if (size == 0)
        return (src_len);
    /* copy at most size-1 bytes, then null-terminate */
    i = 0;
    while (i < size - 1 && src[i]) {
        dst[i] = src[i];
        i++;
    }
    dst[i] = '\0';
    return (src_len);
}
