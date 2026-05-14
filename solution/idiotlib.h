#ifndef IDIOTLIB_H
# define IDIOTLIB_H

# include <stddef.h>
# include <stdlib.h>

/* memory */
void    *il_memset(void *s, int c, size_t n);
void    *il_memcpy(void *dst, const void *src, size_t n);
void    *il_memmove(void *dst, const void *src, size_t n);
void    *il_memchr(const void *s, int c, size_t n);
void     il_bzero(void *s, size_t n);
void    *il_calloc(size_t count, size_t size);

/* character classification */
int      il_isascii(int c);
int      il_isalpha(int c);
int      il_isdigit(int c);
int      il_isalnum(int c);
int      il_isspace(int c);
int      il_isupper(int c);
int      il_islower(int c);
int      il_isprint(int c);
int      il_toupper(int c);
int      il_tolower(int c);

/* strings */
size_t   il_strlen(const char *s);
char    *il_strcpy(char *dst, const char *src);
char    *il_strncpy(char *dst, const char *src, size_t n);
size_t   il_strlcpy(char *dst, const char *src, size_t size);
size_t   il_strlcat(char *dst, const char *src, size_t size);
int      il_strcmp(const char *s1, const char *s2);
int      il_strncmp(const char *s1, const char *s2, size_t n);
char    *il_strchr(const char *s, int c);
char    *il_strrchr(const char *s, int c);
char    *il_strdup(const char *s);
char    *il_strndup(const char *s, size_t n);
char    *il_strnstr(const char *haystack, const char *needle, size_t len);
int      il_atoi(const char *str);

/* lists */
typedef struct s_list {
    void            *content;
    struct s_list   *next;
}   t_list;

t_list  *il_lstnew(void *content);
void     il_lstadd_front(t_list **lst, t_list *new);
void     il_lstadd_back(t_list **lst, t_list *new);
int      il_lstsize(t_list *lst);
t_list  *il_lstlast(t_list *lst);
void     il_lstdelone(t_list *lst, void (*del)(void *));
void     il_lstclear(t_list **lst, void (*del)(void *));
void     il_lstiter(t_list *lst, void (*f)(void *));
t_list  *il_lstmap(t_list *lst, void *(*f)(void *), void (*del)(void *));

#endif
