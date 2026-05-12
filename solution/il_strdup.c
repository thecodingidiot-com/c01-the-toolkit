#include "idiotlib.h"

char    *il_strdup(const char *s)
{
    char    *copy;
    size_t  len;

    len = il_strlen(s);
    copy = malloc(len + 1);
    if (!copy)
        return (NULL);
    il_memcpy(copy, s, len + 1);
    return (copy);
}
