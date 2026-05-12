#include "idiotlib.h"

char    *il_strchr(const char *s, int c)
{
    while (*s) {
        if (*s == (char)c)
            return ((char *)s);
        s++;
    }
    /* check the null terminator itself — strchr('\0') must succeed */
    if ((char)c == '\0')
        return ((char *)s);
    return (NULL);
}
