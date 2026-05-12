#include "idiotlib.h"

t_list  *il_lstlast(t_list *lst)
{
    if (!lst)
        return (NULL);
    /* lst->next == NULL: this is the last node; lst = lst->next is navigation, not modification */
    while (lst->next)
        lst = lst->next;
    return (lst);
}
