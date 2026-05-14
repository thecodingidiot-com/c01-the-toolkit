NAME    = libidiot.a
CC      = gcc
CFLAGS  = -Wall -Wextra -g -std=c99
AR      = ar rcs

SRCS    = il_memset.c il_memcpy.c il_memmove.c il_memchr.c il_bzero.c \
          il_calloc.c \
          il_isascii.c il_isalpha.c il_isdigit.c il_isalnum.c il_isspace.c \
          il_isupper.c il_islower.c il_isprint.c \
          il_toupper.c il_tolower.c \
          il_strlen.c il_strcpy.c il_strncpy.c \
          il_strlcpy.c il_strlcat.c \
          il_strcmp.c il_strncmp.c \
          il_strchr.c il_strrchr.c \
          il_strdup.c il_strndup.c il_strnstr.c il_atoi.c

OBJS    = $(SRCS:.c=.o)

.PHONY: all clean fclean re

all: $(NAME)

$(NAME): $(OBJS)
	$(AR) $(NAME) $(OBJS)

%.o: %.c idiotlib.h
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME)

re: fclean all
