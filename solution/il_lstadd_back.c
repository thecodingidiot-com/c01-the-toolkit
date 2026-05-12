#include "idiotlib.h"

void    il_lstadd_back(t_list **lst, t_list *new)
{
    t_list  *last;

    if (!*lst) {
        *lst = new;
        return;
    }
    last = il_lstlast(*lst);
    last->next = new;
}
