#include "idiotlib.h"

void    il_lstclear(t_list **lst, void (*del)(void *))
{
    t_list  *next;

    while (*lst) {
        next = (*lst)->next;
        il_lstdelone(*lst, del);
        *lst = next;
    }
}
