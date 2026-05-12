#include "idiotlib.h"

int     il_lstsize(t_list *lst)
{
    int  size;

    size = 0;
    while (lst) {
        lst = lst->next;
        size++;
    }
    return (size);
}
