NAME    = libtci.a
CC      = gcc
CFLAGS  = -Wall -Wextra -Werror -std=c99
BUILD   = -g -O0
RELEASE = -O2
AR      = ar rcs

SRCS    = tci_memset.c tci_memcpy.c tci_memmove.c tci_memchr.c tci_bzero.c \
          tci_calloc.c \
          tci_isascii.c tci_isalpha.c tci_isdigit.c tci_isalnum.c tci_isspace.c \
          tci_isupper.c tci_islower.c tci_isprint.c \
          tci_toupper.c tci_tolower.c \
          tci_strlen.c tci_strcpy.c tci_strncpy.c \
          tci_strlcpy.c tci_strlcat.c \
          tci_strcmp.c tci_strncmp.c \
          tci_strchr.c tci_strrchr.c \
          tci_strdup.c tci_strndup.c tci_strnstr.c tci_atoi.c

OBJS    = $(SRCS:.c=.o)

.PHONY: all release clean fclean re

all: $(NAME)

$(NAME): $(OBJS)
	$(AR) $(NAME) $(OBJS)

%.o: %.c libtci.h
	$(CC) $(CFLAGS) $(BUILD) -c $< -o $@

release:
	@$(MAKE) --no-print-directory fclean
	@$(MAKE) --no-print-directory BUILD="$(RELEASE)"
	strip --strip-debug $(NAME)

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME)

re: fclean all
