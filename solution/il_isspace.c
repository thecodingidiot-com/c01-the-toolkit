#include "idiotlib.h"

int     il_isspace(int c)
{
    return (c == ' ' || c == '\t' || c == '\n'
        || c == '\v' || c == '\f' || c == '\r');
}
