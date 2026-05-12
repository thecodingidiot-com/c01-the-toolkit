#include "idiotlib.h"

int     il_atoi(const char *str)
{
    int sign;
    int result;

    while (il_isspace((unsigned char)*str))
        str++;
    sign = 1;
    if (*str == '-' || *str == '+') {
        if (*str == '-')
            sign = -1;
        str++;
    }
    result = 0;
    while (il_isdigit((unsigned char)*str))
        result = result * 10 + (*str++ - '0');
    /* stops at the first non-digit: no error on trailing garbage */
    return (sign * result);
}
