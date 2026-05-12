#include "idiotlib.h"

void    il_lstiter(t_list *lst, void (*f)(void *))
{
    while (lst) {
        f(lst->content);
        lst = lst->next;
    }
}
