#include "idiotlib.h"

int     il_isprint(int c)
{
    return (c >= 32 && c <= 126);
}
