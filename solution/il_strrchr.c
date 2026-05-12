#include "idiotlib.h"

char    *il_strrchr(const char *s, int c)
{
    const char  *last;

    last = NULL;
    while (*s) {
        if (*s == (char)c)
            last = s;
        s++;
    }
    /* check the null terminator itself */
    if ((char)c == '\0')
        return ((char *)s);
    return ((char *)last);
}
