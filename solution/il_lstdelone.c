#include "idiotlib.h"

void    il_lstdelone(t_list *lst, void (*del)(void *))
{
    del(lst->content);
    free(lst);
}
