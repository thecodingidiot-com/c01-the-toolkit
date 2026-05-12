#include "idiotlib.h"

void    il_lstdelone(t_list *lst, void (*del)(void *))
{
    /* del frees whatever content points at; free(lst) frees the node struct itself */
    del(lst->content);
    free(lst);
}
