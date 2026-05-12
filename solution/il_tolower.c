#include "idiotlib.h"

int     il_tolower(int c)
{
    if (c >= 'A' && c <= 'Z')
        return (c + 32);    /* same 32-byte gap in the opposite direction */
    return (c);
}
