# c01-the-toolkit

Companion repository for **c01 — The Toolkit** at
[thecodingidiot.com](https://thecodingidiot.com).

---

## Follow my journey

Working through c01 alongside the implementation pages? Build idiotlib function
by function, then run the tester.

Clone this repository and copy `test.sh` into your working directory:

```bash
git clone https://github.com/thecodingidiot-com/c01-the-toolkit.git
cp c01-the-toolkit/test.sh ~/c01-practice/
cd ~/c01-practice
bash test.sh
```

All 5 checks must pass before the chapter is complete.

---

## Follow your journey

Building idiotlib independently? Here is the full project brief.

**Target:** `libidiot.a` — a static library compiled with
`gcc -Wall -Wextra -g -std=c99`, no warnings.

**Functions to implement** (one `.c` file each):

Memory: `il_memset`, `il_memcpy`, `il_memmove`, `il_memchr`, `il_bzero`,
`il_calloc`

Character: `il_isascii`, `il_isalpha`, `il_isdigit`, `il_isalnum`,
`il_isspace`, `il_isupper`, `il_islower`, `il_isprint`, `il_toupper`,
`il_tolower`

Strings: `il_strlen`, `il_strcpy`, `il_strncpy`, `il_strlcpy`, `il_strlcat`,
`il_strcmp`, `il_strncmp`, `il_strchr`, `il_strrchr`, `il_strdup`,
`il_strnstr`, `il_atoi`

Lists: `il_lstnew`, `il_lstadd_front`, `il_lstadd_back`, `il_lstsize`,
`il_lstlast`, `il_lstdelone`, `il_lstclear`, `il_lstiter`, `il_lstmap`

**Header:** `idiotlib.h` — declares all 37 functions and the `t_list` type.

**Build target:** `make re` must produce `libidiot.a`.

Build and test your own version first. Use `solution/` to compare once you
are done, not before.

---

## What the tester checks

1. **make re** — clean rebuild; `libidiot.a` produced; no compiler warnings.
2. **compile** — links an embedded test runner against your `libidiot.a`.
3. **correctness** — runs the test runner; every check must pass.
   - Memory and character functions are compared against their libc counterparts.
   - `strlcpy`, `strlcat`, and `strnstr` are tested against embedded reference
     implementations (glibc does not include them).
   - List functions are tested against their specification.
4. **valgrind** — runs the test runner under valgrind; no leaks or errors.
5. **sanitisers** — recompiles `il_*.c` with `-fsanitize=address,undefined`
   and runs the result; no sanitiser errors.

---

## License

GPLv2. See [LICENSE](LICENSE).
