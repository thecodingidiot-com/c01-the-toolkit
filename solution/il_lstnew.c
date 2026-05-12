#include "idiotlib.h"

t_list  *il_lstnew(void *content)
{
    t_list  *node;

    node = malloc(sizeof(t_list));  /* allocates the node struct, not the content — the caller owns what content points at */
    if (!node)
        return (NULL);
    node->content = content;
    node->next = NULL;              /* a freshly allocated node is not in a list yet */
    return (node);
}
