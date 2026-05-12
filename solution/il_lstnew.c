#include "idiotlib.h"

t_list  *il_lstnew(void *content)
{
    t_list  *node;

    node = malloc(sizeof(t_list));
    if (!node)
        return (NULL);
    node->content = content;
    node->next = NULL;
    return (node);
}
