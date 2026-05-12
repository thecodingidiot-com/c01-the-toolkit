#include "idiotlib.h"

int     il_isascii(int c)
{
    /* 0–127 covers the 7-bit ASCII table; nothing higher is ASCII */
    return (c >= 0 && c <= 127);
}
