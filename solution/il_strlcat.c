#include "idiotlib.h"

size_t  il_strlcat(char *dst, const char *src, size_t size)
{
    size_t  dst_len;
    size_t  src_len;
    size_t  i;

    dst_len = il_strlen(dst);
    src_len = il_strlen(src);
    /* if dst is already at or beyond size, no room to append */
    if (size <= dst_len)
        return (size + src_len);
    i = 0;
    while (src[i] && dst_len + i < size - 1) {
        dst[dst_len + i] = src[i];
        i++;
    }
    dst[dst_len + i] = '\0';
    /* return dst_len + src_len regardless of truncation, for the same reason */
    return (dst_len + src_len);
}
