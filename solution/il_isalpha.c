#include "idiotlib.h"

int     il_isalpha(int c)
{
    /* two separate ranges: locale-independent, always valid for ASCII */
    return ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z'));
}
