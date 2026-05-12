#include "idiotlib.h"

int     il_toupper(int c)
{
    if (c >= 'a' && c <= 'z')
        return (c - 32);    /* 'a' is 97, 'A' is 65: the distance between cases is always 32 */
    return (c);
}
