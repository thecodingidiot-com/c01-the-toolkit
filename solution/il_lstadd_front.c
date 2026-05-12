#include "idiotlib.h"

void    il_lstadd_front(t_list **lst, t_list *new)
{
    new->next = *lst;
    *lst = new;
}
