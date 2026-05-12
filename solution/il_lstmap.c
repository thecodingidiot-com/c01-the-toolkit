#include "idiotlib.h"

t_list  *il_lstmap(t_list *lst, void *(*f)(void *), void (*del)(void *))
{
    t_list  *result;
    t_list  *node;
    void    *content;

    result = NULL;
    while (lst) {
        content = f(lst->content);
        if (!content) {
            /* f signals failure: it owns the content, we clean up what we built */
            il_lstclear(&result, del);
            return (NULL);
        }
        node = il_lstnew(content);
        if (!node) {
            /* allocation failed: del the just-transformed content, clean the rest */
            del(content);
            il_lstclear(&result, del);
            return (NULL);
        }
        il_lstadd_back(&result, node);
        lst = lst->next;
    }
    /* original list is not freed or modified: caller owns both lists */
    return (result);
}
