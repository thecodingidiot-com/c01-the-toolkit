#include "idiotlib.h"

void    il_lstclear(t_list **lst, void (*del)(void *))
{
    t_list  *next;

    while (*lst) {
        next = (*lst)->next;    /* save next before il_lstdelone: reading lst->next after free is undefined behaviour */
        il_lstdelone(*lst, del);
        *lst = next;
    }
}
