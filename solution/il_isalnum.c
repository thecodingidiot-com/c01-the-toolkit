#include "idiotlib.h"

int     il_isalnum(int c)
{
    return (il_isalpha(c) || il_isdigit(c));
}
