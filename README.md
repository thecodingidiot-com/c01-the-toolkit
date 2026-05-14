# c01-the-toolkit

Companion repository for **c01 — The Toolkit** at
[thecodingidiot.com](https://thecodingidiot.com).

---

## Follow my journey

Working through c01 alongside the implementation pages? Build libtci function
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

Building libtci independently? Here is the full project brief.

**Target:** `libtci.a` — a static library compiled with
`gcc -Wall -Wextra -g -std=c99`, no warnings.

**Functions to implement** (one `.c` file each):

Memory: `tci_memset`, `tci_memcpy`, `tci_memmove`, `tci_memchr`, `tci_bzero`,
`tci_calloc`

Character: `tci_isascii`, `tci_isalpha`, `tci_isdigit`, `tci_isalnum`,
`tci_isspace`, `tci_isupper`, `tci_islower`, `tci_isprint`, `tci_toupper`,
`tci_tolower`

Strings: `tci_strlen`, `tci_strcpy`, `tci_strncpy`, `tci_strlcpy`, `tci_strlcat`,
`tci_strcmp`, `tci_strncmp`, `tci_strchr`, `tci_strrchr`, `tci_strdup`,
`tci_strndup`, `tci_strnstr`, `tci_atoi`

**Header:** `libtci.h` — declares all 29 functions.

**Build target:** `make re` must produce `libtci.a`.

Build and test your own version first. Use `solution/` to compare once you
are done, not before.

---

## What the tester checks

1. **make re** — clean rebuild; `libtci.a` produced; no compiler warnings.
2. **compile** — links an embedded test runner against your `libtci.a`.
3. **correctness** — runs the test runner; every check must pass.
   - Memory and character functions are compared against their libc counterparts.
   - `strlcpy`, `strlcat`, and `strnstr` are tested against embedded reference
     implementations (glibc does not include them).
4. **valgrind** — runs the test runner under valgrind; no leaks or errors.
5. **sanitisers** — recompiles `tci_*.c` with `-fsanitize=address,undefined`
   and runs the result; no sanitiser errors.

---

## License

GPLv2. See [LICENSE](LICENSE).
