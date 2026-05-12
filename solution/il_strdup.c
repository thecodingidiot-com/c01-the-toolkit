#include "idiotlib.h"

char    *il_strdup(const char *s)
{
    char    *copy;
    size_t  len;

    len = il_strlen(s);
    copy = malloc(len + 1);     /* +1 for the null terminator */
    if (!copy)
        return (NULL);
    il_memcpy(copy, s, len + 1);    /* copies len+1 bytes to include the terminator */
    return (copy);
}
