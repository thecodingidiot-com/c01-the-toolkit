#include "idiotlib.h"

void    il_lstiter(t_list *lst, void (*f)(void *))
{
    while (lst) {
        f(lst->content);
        lst = lst->next;    /* navigation only — lst = lst->next does not write into any node */
    }
}
