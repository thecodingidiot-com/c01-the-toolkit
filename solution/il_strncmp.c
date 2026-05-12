#include "idiotlib.h"

int     il_strncmp(const char *s1, const char *s2, size_t n)
{
    if (n == 0)
        return (0);
    while (n > 1 && *s1 && *s1 == *s2) {
        s1++;
        s2++;
        n--;
    }
    return ((unsigned char)*s1 - (unsigned char)*s2);
}
