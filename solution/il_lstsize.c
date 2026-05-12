#include "idiotlib.h"

int     il_lstsize(t_list *lst)
{
    int  size;

    /* int return, not size_t — lists are never large enough for the difference to matter */
    size = 0;
    while (lst) {
        lst = lst->next;
        size++;
    }
    return (size);
}
