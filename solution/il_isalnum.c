#include "idiotlib.h"

int     il_isalnum(int c)
{
    /* delegates to the two predicates: any letter or decimal digit */
    return (il_isalpha(c) || il_isdigit(c));
}
