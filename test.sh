#!/bin/bash
# c01 — The Toolkit / test.sh
#
# Tests libidiot.a against libc and spec.
# Copy this file into your working directory alongside libidiot.a and all
# il_*.c source files, then run:
#
#   bash test.sh

set -o pipefail

# ── colour ───────────────────────────────────────────────────────────────────

if [[ ! -t 1 ]]; then
    C_GREEN=""
    C_RED=""
    C_BOLD=""
    C_RESET=""
else
    C_GREEN="\033[0;32m"
    C_RED="\033[0;31m"
    C_BOLD="\033[1m"
    C_RESET="\033[0m"
fi

# ── state ─────────────────────────────────────────────────────────────────────

pass_count=0
fail_count=0
WORK_DIR=$(mktemp -d)

# ── cleanup ───────────────────────────────────────────────────────────────────

cleanup() {
    rm -f _runner _runner.c _runner_san
    rm -rf "$WORK_DIR"
}
trap cleanup EXIT

# ── helpers ───────────────────────────────────────────────────────────────────

hr() {
    echo "────────────────────────────────────────────────────────────────"
}

banner() {
    hr
    echo "  c01 — The Toolkit / test.sh"
    hr
}

pass() {
    local label="$1"
    printf "  ${C_GREEN}PASS${C_RESET}  %s\n" "$label"
    pass_count=$((pass_count + 1))
}

fail() {
    local label="$1"
    printf "  ${C_RED}FAIL${C_RESET}  %s\n" "$label"
    fail_count=$((fail_count + 1))
}

# ── pre-flight ────────────────────────────────────────────────────────────────

preflight() {
    local ok=1
    for tool in gcc make valgrind; do
        if ! command -v "$tool" &>/dev/null; then
            echo "error: $tool is not installed" >&2
            ok=0
        fi
    done
    if [[ ! -f Makefile ]]; then
        echo "error: Makefile not found in current directory" >&2
        ok=0
    fi
    if [[ $ok -eq 0 ]]; then
        exit 1
    fi
}

# ── embedded C test runner ────────────────────────────────────────────────────

write_runner() {
    cat > _runner.c << 'RUNNER_EOF'
#define _POSIX_C_SOURCE 200809L
#include "idiotlib.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

static int g_pass;
static int g_fail;
static int g_del_count;
static int g_iter_count;

static void check(const char *label, int ok)
{
    if (ok) {
        printf("  PASS  %s\n", label);
        g_pass++;
    } else {
        printf("  FAIL  %s\n", label);
        g_fail++;
    }
}

/* ── reference implementations for BSD-only functions ── */

static size_t ref_strlcpy(char *dst, const char *src, size_t size)
{
    size_t src_len;
    size_t i;

    src_len = strlen(src);
    if (size == 0)
        return (src_len);
    i = 0;
    while (i < size - 1 && src[i]) {
        dst[i] = src[i];
        i++;
    }
    dst[i] = '\0';
    return (src_len);
}

static size_t ref_strlcat(char *dst, const char *src, size_t size)
{
    size_t dst_len;
    size_t src_len;
    size_t i;

    dst_len = strlen(dst);
    src_len = strlen(src);
    if (size <= dst_len)
        return (size + src_len);
    i = 0;
    while (src[i] && dst_len + i < size - 1) {
        dst[dst_len + i] = src[i];
        i++;
    }
    dst[dst_len + i] = '\0';
    return (dst_len + src_len);
}

static char *ref_strnstr(const char *h, const char *needle, size_t len)
{
    size_t nlen;
    size_t i;
    size_t j;

    if (!*needle)
        return ((char *)h);
    nlen = strlen(needle);
    for (i = 0; i < len && h[i]; i++) {
        if (i + nlen > len)
            break;
        j = 0;
        while (j < nlen && h[i + j] == needle[j])
            j++;
        if (j == nlen)
            return ((char *)(h + i));
    }
    return (NULL);
}

/* ── helpers for list tests ── */

static void count_del(void *p)
{
    free(p);
    g_del_count++;
}

static void count_iter(void *p)
{
    (void)p;
    g_iter_count++;
}

static void *dup_content(void *p)
{
    return (strdup((char *)p));
}

/* ────────────────────────────────── memory ── */

static void test_memset(void)
{
    char buf1[16];
    char buf2[16];
    void *ret;

    memset(buf1, 'X', 10);
    il_memset(buf2, 'X', 10);
    check("memset: fill 10 bytes", memcmp(buf1, buf2, 10) == 0);

    memset(buf1, 0, 16);
    il_memset(buf2, 0, 16);
    check("memset: zero fill", memcmp(buf1, buf2, 16) == 0);

    memset(buf1, 255, 1);
    il_memset(buf2, 255, 1);
    check("memset: n=1", buf1[0] == buf2[0]);

    buf2[0] = 'A';
    il_memset(buf2, 'Z', 0);
    check("memset: n=0 unchanged", buf2[0] == 'A');

    ret = il_memset(buf2, 'Q', 5);
    check("memset: returns s", ret == (void *)buf2);
}

static void test_memcpy(void)
{
    char src[16];
    char dst1[16];
    char dst2[16];
    void *ret;

    memset(src, 0, 16);
    memcpy(src, "hello, world!", 14);
    memset(dst1, 0, 16);
    memset(dst2, 0, 16);
    memcpy(dst1, src, 14);
    il_memcpy(dst2, src, 14);
    check("memcpy: basic", memcmp(dst1, dst2, 14) == 0);

    memset(dst1, 'A', 4);
    memset(dst2, 'A', 4);
    memcpy(dst1, src, 0);
    il_memcpy(dst2, src, 0);
    check("memcpy: n=0 unchanged", memcmp(dst1, dst2, 4) == 0);

    memcpy(dst1, src, 1);
    il_memcpy(dst2, src, 1);
    check("memcpy: n=1", dst1[0] == dst2[0]);

    ret = il_memcpy(dst2, src, 5);
    check("memcpy: returns dst", ret == (void *)dst2);
}

static void test_memmove(void)
{
    char buf1[32];
    char buf2[32];
    void *ret;

    /* non-overlapping */
    memset(buf1, 0, 32);
    memset(buf2, 0, 32);
    memcpy(buf1, "abcdefghij", 10);
    memcpy(buf2, "abcdefghij", 10);
    memmove(buf1 + 15, buf1, 10);
    il_memmove(buf2 + 15, buf2, 10);
    check("memmove: non-overlapping", memcmp(buf1 + 15, buf2 + 15, 10) == 0);

    /* dst > src, overlap: copy "abcde" 2 bytes forward */
    memcpy(buf1, "abcde", 5);
    memcpy(buf2, "abcde", 5);
    memmove(buf1 + 2, buf1, 5);
    il_memmove(buf2 + 2, buf2, 5);
    check("memmove: dst>src overlap", memcmp(buf1, buf2, 8) == 0);

    /* dst < src, overlap: shift left by 1 */
    memcpy(buf1, "abcde", 5);
    memcpy(buf2, "abcde", 5);
    memmove(buf1, buf1 + 1, 4);
    il_memmove(buf2, buf2 + 1, 4);
    check("memmove: dst<src overlap", memcmp(buf1, buf2, 5) == 0);

    ret = il_memmove(buf2, buf2, 3);
    check("memmove: returns dst", ret == (void *)buf2);

    buf2[0] = 'Z';
    il_memmove(buf2, buf2 + 1, 0);
    check("memmove: n=0 unchanged", buf2[0] == 'Z');
}

static void test_memchr(void)
{
    const char *s = "hello world";

    check("memchr: found",
        il_memchr(s, 'o', 11) == memchr(s, 'o', 11));
    check("memchr: not found",
        il_memchr(s, 'z', 11) == memchr(s, 'z', 11));
    check("memchr: found before n",
        il_memchr(s, 'o', 4) == memchr(s, 'o', 4));
    check("memchr: n=0 returns NULL",
        il_memchr(s, 'o', 0) == NULL);
    check("memchr: find null byte",
        il_memchr(s, '\0', 12) == memchr(s, '\0', 12));
}

static void test_bzero(void)
{
    char buf[16];

    memset(buf, 'A', 16);
    il_bzero(buf, 10);
    check("bzero: 10 bytes zeroed",
        buf[0] == 0 && buf[9] == 0 && buf[10] == 'A');

    memset(buf, 'B', 4);
    il_bzero(buf, 0);
    check("bzero: n=0 unchanged", buf[0] == 'B');

    memset(buf, 'C', 1);
    il_bzero(buf, 1);
    check("bzero: n=1", buf[0] == 0);
}

static void test_calloc(void)
{
    char   *p;
    int     all_zero;
    int     i;

    p = (char *)il_calloc(8, 1);
    all_zero = 1;
    for (i = 0; i < 8; i++)
        if (p[i] != 0)
            all_zero = 0;
    check("calloc: 8 bytes zeroed", all_zero);
    free(p);

    p = (char *)il_calloc(4, 4);
    all_zero = 1;
    for (i = 0; i < 16; i++)
        if (p[i] != 0)
            all_zero = 0;
    check("calloc: 4*4 zeroed", all_zero);
    free(p);

    /* count=0: must not crash; free(NULL) is a no-op */
    p = (char *)il_calloc(0, 1);
    check("calloc: count=0 no crash", 1);
    free(p);

    /* overflow: SIZE_MAX * 2 wraps — must return NULL */
    p = (char *)il_calloc((size_t)-1, 2);
    check("calloc: overflow returns NULL", p == NULL);
}

/* ────────────────────────────────── character ── */

static void test_isascii(void)
{
    int c;
    int ok;

    /* spec: non-zero for 0-127, zero for 128-255 */
    ok = 1;
    for (c = 0; c <= 127; c++)
        if (il_isascii(c) == 0)
            ok = 0;
    check("isascii: 0-127 all non-zero", ok);

    ok = 1;
    for (c = 128; c <= 255; c++)
        if (il_isascii(c) != 0)
            ok = 0;
    check("isascii: 128-255 all zero", ok);
}

static void test_isalpha(void)
{
    int c;
    int ok;

    ok = 1;
    for (c = 0; c <= 127; c++)
        if ((il_isalpha(c) != 0) != (isalpha(c) != 0))
            ok = 0;
    check("isalpha: 0-127 match libc", ok);
    check("isalpha: 'A' is alpha", il_isalpha('A') != 0);
    check("isalpha: '1' not alpha", il_isalpha('1') == 0);
}

static void test_isdigit(void)
{
    int c;
    int ok;

    ok = 1;
    for (c = 0; c <= 127; c++)
        if ((il_isdigit(c) != 0) != (isdigit(c) != 0))
            ok = 0;
    check("isdigit: 0-127 match libc", ok);
    check("isdigit: '5' is digit", il_isdigit('5') != 0);
    check("isdigit: 'a' not digit", il_isdigit('a') == 0);
}

static void test_isalnum(void)
{
    int c;
    int ok;

    ok = 1;
    for (c = 0; c <= 127; c++)
        if ((il_isalnum(c) != 0) != (isalnum(c) != 0))
            ok = 0;
    check("isalnum: 0-127 match libc", ok);
    check("isalnum: 'Z' is alnum", il_isalnum('Z') != 0);
    check("isalnum: '9' is alnum", il_isalnum('9') != 0);
}

static void test_isspace(void)
{
    int c;
    int ok;

    ok = 1;
    for (c = 0; c <= 127; c++)
        if ((il_isspace(c) != 0) != (isspace(c) != 0))
            ok = 0;
    check("isspace: 0-127 match libc", ok);
    check("isspace: ' ' is space", il_isspace(' ') != 0);
    check("isspace: 'a' not space", il_isspace('a') == 0);
}

static void test_isupper(void)
{
    int c;
    int ok;

    ok = 1;
    for (c = 0; c <= 127; c++)
        if ((il_isupper(c) != 0) != (isupper(c) != 0))
            ok = 0;
    check("isupper: 0-127 match libc", ok);
    check("isupper: 'A' is upper", il_isupper('A') != 0);
    check("isupper: 'a' not upper", il_isupper('a') == 0);
}

static void test_islower(void)
{
    int c;
    int ok;

    ok = 1;
    for (c = 0; c <= 127; c++)
        if ((il_islower(c) != 0) != (islower(c) != 0))
            ok = 0;
    check("islower: 0-127 match libc", ok);
    check("islower: 'a' is lower", il_islower('a') != 0);
    check("islower: 'A' not lower", il_islower('A') == 0);
}

static void test_isprint(void)
{
    int c;
    int ok;

    ok = 1;
    for (c = 0; c <= 127; c++)
        if ((il_isprint(c) != 0) != (isprint(c) != 0))
            ok = 0;
    check("isprint: 0-127 match libc", ok);
    check("isprint: ' ' is printable", il_isprint(' ') != 0);
    check("isprint: '\\n' not printable", il_isprint('\n') == 0);
}

static void test_toupper(void)
{
    int c;
    int ok;

    ok = 1;
    for (c = 0; c <= 127; c++)
        if (il_toupper(c) != toupper(c))
            ok = 0;
    check("toupper: 0-127 match libc", ok);
    check("toupper: 'a' -> 'A'", il_toupper('a') == 'A');
    check("toupper: 'A' unchanged", il_toupper('A') == 'A');
    check("toupper: '1' unchanged", il_toupper('1') == '1');
}

static void test_tolower(void)
{
    int c;
    int ok;

    ok = 1;
    for (c = 0; c <= 127; c++)
        if (il_tolower(c) != tolower(c))
            ok = 0;
    check("tolower: 0-127 match libc", ok);
    check("tolower: 'A' -> 'a'", il_tolower('A') == 'a');
    check("tolower: 'a' unchanged", il_tolower('a') == 'a');
    check("tolower: '1' unchanged", il_tolower('1') == '1');
}

/* ────────────────────────────────── strings ── */

static void test_strlen(void)
{
    check("strlen: empty",    il_strlen("") == strlen(""));
    check("strlen: 'hello'",  il_strlen("hello") == strlen("hello"));
    check("strlen: 1 char",   il_strlen("x") == 1);
    check("strlen: 3 chars",  il_strlen("abc") == 3);
    check("strlen: 26 chars",
        il_strlen("abcdefghijklmnopqrstuvwxyz") == 26);
}

static void test_strcpy(void)
{
    char buf1[64];
    char buf2[64];
    char *ret;

    strcpy(buf1, "hello");
    il_strcpy(buf2, "hello");
    check("strcpy: basic", strcmp(buf1, buf2) == 0);

    strcpy(buf1, "");
    il_strcpy(buf2, "");
    check("strcpy: empty src", strcmp(buf1, buf2) == 0);

    ret = il_strcpy(buf2, "test");
    check("strcpy: returns dst", ret == buf2);
    check("strcpy: null-terminated", buf2[4] == '\0');
}

static void test_strncpy(void)
{
    char buf[16];

    /* copy "hello" into 8 bytes: 5 chars + 3 null bytes */
    memset(buf, 'X', 16);
    il_strncpy(buf, "hello", 8);
    check("strncpy: copy + null-pad", memcmp(buf, "hello\0\0\0", 8) == 0);

    /* truncate to 3: no null terminator written inside the 3 bytes */
    memset(buf, 'X', 16);
    il_strncpy(buf, "hello", 3);
    check("strncpy: truncate to 3", memcmp(buf, "hel", 3) == 0 && buf[3] == 'X');

    /* empty src: n bytes all null */
    memset(buf, 'X', 16);
    il_strncpy(buf, "", 4);
    check("strncpy: empty src zeroes n bytes",
        buf[0] == '\0' && buf[1] == '\0' && buf[2] == '\0' && buf[3] == '\0');

    /* n=0: nothing touched */
    memset(buf, 'X', 16);
    il_strncpy(buf, "hi", 0);
    check("strncpy: n=0 buffer unchanged", buf[0] == 'X');
}

static void test_strlcpy(void)
{
    char   dst1[16];
    char   dst2[16];
    size_t r1;
    size_t r2;

    memset(dst1, 'X', 16);
    memset(dst2, 'X', 16);
    r1 = ref_strlcpy(dst1, "hello", 10);
    r2 = il_strlcpy(dst2, "hello", 10);
    check("strlcpy: basic copy", strcmp(dst1, dst2) == 0);
    check("strlcpy: basic return value", r1 == r2);

    memset(dst1, 'X', 16);
    memset(dst2, 'X', 16);
    r1 = ref_strlcpy(dst1, "hello", 3);
    r2 = il_strlcpy(dst2, "hello", 3);
    check("strlcpy: truncate", strcmp(dst1, dst2) == 0);
    check("strlcpy: truncate return value", r1 == r2);

    /* size=0: no write, return src length */
    r1 = ref_strlcpy(dst1, "hello", 0);
    r2 = il_strlcpy(dst2, "hello", 0);
    check("strlcpy: size=0 return value", r1 == r2);

    memset(dst1, 'X', 16);
    memset(dst2, 'X', 16);
    r1 = ref_strlcpy(dst1, "", 4);
    r2 = il_strlcpy(dst2, "", 4);
    check("strlcpy: empty src", strcmp(dst1, dst2) == 0 && r1 == r2);
}

static void test_strlcat(void)
{
    char   dst1[16];
    char   dst2[16];
    size_t r1;
    size_t r2;

    strcpy(dst1, "hi");
    strcpy(dst2, "hi");
    r1 = ref_strlcat(dst1, " world", 16);
    r2 = il_strlcat(dst2, " world", 16);
    check("strlcat: basic append", strcmp(dst1, dst2) == 0);
    check("strlcat: basic return value", r1 == r2);

    strcpy(dst1, "hello");
    strcpy(dst2, "hello");
    r1 = ref_strlcat(dst1, " world", 8);
    r2 = il_strlcat(dst2, " world", 8);
    check("strlcat: truncate", strcmp(dst1, dst2) == 0);
    check("strlcat: truncate return value", r1 == r2);

    /* size <= dst_len: no write, return size + src_len */
    strcpy(dst1, "abcdef");
    strcpy(dst2, "abcdef");
    r1 = ref_strlcat(dst1, "XYZ", 4);
    r2 = il_strlcat(dst2, "XYZ", 4);
    check("strlcat: size<=dstlen return value", r1 == r2);

    strcpy(dst1, "hi");
    strcpy(dst2, "hi");
    r1 = ref_strlcat(dst1, "", 16);
    r2 = il_strlcat(dst2, "", 16);
    check("strlcat: empty src", strcmp(dst1, dst2) == 0 && r1 == r2);
}

static void test_strcmp(void)
{
    int r1;
    int r2;
    int ok;

#define SCMP(a, b) \
    r1 = strcmp((a), (b)); r2 = il_strcmp((a), (b)); \
    ok = ((r1 < 0) == (r2 < 0)) && \
         ((r1 == 0) == (r2 == 0)) && \
         ((r1 > 0) == (r2 > 0)); \
    check("strcmp: " #a " vs " #b, ok)

    SCMP("abc", "abc");
    SCMP("abc", "abd");
    SCMP("abd", "abc");
    SCMP("", "");
    SCMP("a", "");
    SCMP("", "a");
    SCMP("abc", "abcd");
#undef SCMP
}

static void test_strncmp(void)
{
    int r1;
    int r2;
    int ok;

#define SNCMP(a, b, n) \
    r1 = strncmp((a), (b), (n)); r2 = il_strncmp((a), (b), (n)); \
    ok = ((r1 < 0) == (r2 < 0)) && \
         ((r1 == 0) == (r2 == 0)) && \
         ((r1 > 0) == (r2 > 0)); \
    check("strncmp: " #a " vs " #b " n=" #n, ok)

    SNCMP("abc", "abc", 3);
    SNCMP("abc", "abd", 3);
    SNCMP("abc", "abc", 0);
    SNCMP("abc", "abcd", 3);
    SNCMP("abc", "abcd", 4);
    SNCMP("", "", 1);
#undef SNCMP
}

static void test_strchr(void)
{
    const char *s = "hello world";

    check("strchr: first 'l'",
        il_strchr(s, 'l') == strchr(s, 'l'));
    check("strchr: not found",
        il_strchr(s, 'z') == NULL);
    check("strchr: find null terminator",
        il_strchr(s, '\0') == strchr(s, '\0'));
    check("strchr: first char",
        il_strchr(s, 'h') == s);
    check("strchr: last char",
        il_strchr(s, 'd') == s + 10);
}

static void test_strrchr(void)
{
    const char *s = "hello world";

    check("strrchr: last 'l'",
        il_strrchr(s, 'l') == strrchr(s, 'l'));
    check("strrchr: not found",
        il_strrchr(s, 'z') == NULL);
    check("strrchr: find null terminator",
        il_strrchr(s, '\0') == strrchr(s, '\0'));
    check("strrchr: single occurrence 'h'",
        il_strrchr(s, 'h') == s);
    check("strrchr: last char 'd'",
        il_strrchr(s, 'd') == s + 10);
}

static void test_strdup(void)
{
    char *p;

    p = il_strdup("hello");
    check("strdup: content matches", strcmp(p, "hello") == 0);
    check("strdup: new allocation", p != NULL);
    free(p);

    p = il_strdup("");
    check("strdup: empty string", strcmp(p, "") == 0);
    free(p);
}

static void test_strnstr(void)
{
    const char *h = "one two three";
    char       *r1;
    char       *r2;

    r1 = ref_strnstr(h, "two", 13);
    r2 = il_strnstr(h, "two", 13);
    check("strnstr: found within len", r1 == r2);

    /* needle starts at position 4, needs 7 bytes: out of bounds for len=5 */
    r1 = ref_strnstr(h, "two", 5);
    r2 = il_strnstr(h, "two", 5);
    check("strnstr: needle past len boundary", r1 == r2);

    r1 = ref_strnstr(h, "", 13);
    r2 = il_strnstr(h, "", 13);
    check("strnstr: empty needle returns haystack", r1 == r2);

    r1 = ref_strnstr(h, "four", 13);
    r2 = il_strnstr(h, "four", 13);
    check("strnstr: not found", r1 == r2);

    /* needle fits exactly at boundary: "one" at offset 0, len=3 */
    r1 = ref_strnstr(h, "one", 3);
    r2 = il_strnstr(h, "one", 3);
    check("strnstr: exact boundary match", r1 == r2);

    r1 = ref_strnstr(h, "three", 13);
    r2 = il_strnstr(h, "three", 13);
    check("strnstr: found at end of string", r1 == r2);
}

static void test_atoi(void)
{
    check("atoi: positive integer",  il_atoi("42") == atoi("42"));
    check("atoi: negative integer",  il_atoi("-17") == atoi("-17"));
    check("atoi: zero",              il_atoi("0") == 0);
    check("atoi: leading spaces",    il_atoi("   7") == atoi("   7"));
    check("atoi: trailing text",     il_atoi("-7 ignored") == atoi("-7 ignored"));
    check("atoi: plus sign",         il_atoi("+5") == atoi("+5"));
}

/* ────────────────────────────────── lists ── */

static void test_lstnew(void)
{
    t_list *n;
    char   *s;

    s = strdup("hello");
    n = il_lstnew(s);
    check("lstnew: content set", n->content == s);
    check("lstnew: next is NULL", n->next == NULL);
    free(n->content);
    free(n);

    n = il_lstnew(NULL);
    check("lstnew: NULL content accepted", n->content == NULL);
    free(n);
}

static void test_lstadd_front(void)
{
    t_list *list;
    t_list *a;
    t_list *b;

    list = NULL;
    a = il_lstnew(strdup("first"));
    il_lstadd_front(&list, a);
    check("lstadd_front: empty list -> a is front", list == a);
    check("lstadd_front: a->next is NULL", a->next == NULL);

    b = il_lstnew(strdup("second"));
    il_lstadd_front(&list, b);
    check("lstadd_front: b becomes new front", list == b);
    check("lstadd_front: b->next is a", b->next == a);

    il_lstclear(&list, free);
}

static void test_lstadd_back(void)
{
    t_list *list;
    t_list *a;
    t_list *b;
    t_list *c;

    list = NULL;
    a = il_lstnew(strdup("first"));
    il_lstadd_back(&list, a);
    check("lstadd_back: empty list -> a is front", list == a);

    b = il_lstnew(strdup("second"));
    il_lstadd_back(&list, b);
    check("lstadd_back: a->next is b", a->next == b);
    check("lstadd_back: b->next is NULL", b->next == NULL);

    c = il_lstnew(strdup("third"));
    il_lstadd_back(&list, c);
    check("lstadd_back: b->next is c", b->next == c);

    il_lstclear(&list, free);
}

static void test_lstsize(void)
{
    t_list *list;

    list = NULL;
    check("lstsize: empty list is 0", il_lstsize(list) == 0);

    il_lstadd_back(&list, il_lstnew(strdup("a")));
    check("lstsize: one node is 1", il_lstsize(list) == 1);

    il_lstadd_back(&list, il_lstnew(strdup("b")));
    il_lstadd_back(&list, il_lstnew(strdup("c")));
    check("lstsize: three nodes is 3", il_lstsize(list) == 3);

    il_lstclear(&list, free);
    check("lstsize: after clear is 0", il_lstsize(list) == 0);
}

static void test_lstlast(void)
{
    t_list *list;
    t_list *a;
    t_list *c;

    check("lstlast: NULL list returns NULL", il_lstlast(NULL) == NULL);

    list = NULL;
    a = il_lstnew(strdup("only"));
    il_lstadd_back(&list, a);
    check("lstlast: single node returns itself", il_lstlast(list) == a);

    c = il_lstnew(strdup("last"));
    il_lstadd_back(&list, il_lstnew(strdup("middle")));
    il_lstadd_back(&list, c);
    check("lstlast: last of three", il_lstlast(list) == c);

    il_lstclear(&list, free);
}

static void test_lstdelone(void)
{
    t_list *n;

    g_del_count = 0;
    n = il_lstnew(strdup("test"));
    il_lstdelone(n, count_del);
    check("lstdelone: del called once", g_del_count == 1);
    /* valgrind confirms no leak */
}

static void test_lstclear(void)
{
    t_list *list;
    int     i;

    list = NULL;
    g_del_count = 0;
    for (i = 0; i < 5; i++)
        il_lstadd_back(&list, il_lstnew(strdup("node")));
    il_lstclear(&list, count_del);
    check("lstclear: del called for every node", g_del_count == 5);
    check("lstclear: list pointer set to NULL", list == NULL);

    il_lstclear(&list, count_del);
    check("lstclear: empty list is safe", list == NULL);
}

static void test_lstiter(void)
{
    t_list *list;
    t_list *node;
    t_list *next;

    list = NULL;
    g_iter_count = 0;
    /* use string literals as content: noop_del so we don't free them */
    il_lstadd_back(&list, il_lstnew("a"));
    il_lstadd_back(&list, il_lstnew("b"));
    il_lstadd_back(&list, il_lstnew("c"));
    il_lstiter(list, count_iter);
    check("lstiter: f called for every node", g_iter_count == 3);

    node = list;
    while (node) {
        next = node->next;
        free(node);
        node = next;
    }
}

static void test_lstmap(void)
{
    t_list *src;
    t_list *res;

    src = NULL;
    il_lstadd_back(&src, il_lstnew(strdup("one")));
    il_lstadd_back(&src, il_lstnew(strdup("two")));
    il_lstadd_back(&src, il_lstnew(strdup("three")));

    res = il_lstmap(src, dup_content, free);

    check("lstmap: result is not NULL", res != NULL);
    check("lstmap: result size matches source",
        il_lstsize(res) == il_lstsize(src));
    check("lstmap: first node content matches",
        strcmp((char *)res->content, "one") == 0);
    check("lstmap: source list is unchanged",
        strcmp((char *)src->content, "one") == 0);

    il_lstclear(&src, free);
    il_lstclear(&res, free);
}

/* ────────────────────────────────── main ── */

int main(void)
{
    /* memory */
    test_memset();
    test_memcpy();
    test_memmove();
    test_memchr();
    test_bzero();
    test_calloc();

    /* character */
    test_isascii();
    test_isalpha();
    test_isdigit();
    test_isalnum();
    test_isspace();
    test_isupper();
    test_islower();
    test_isprint();
    test_toupper();
    test_tolower();

    /* strings */
    test_strlen();
    test_strcpy();
    test_strncpy();
    test_strlcpy();
    test_strlcat();
    test_strcmp();
    test_strncmp();
    test_strchr();
    test_strrchr();
    test_strdup();
    test_strnstr();
    test_atoi();

    /* lists */
    test_lstnew();
    test_lstadd_front();
    test_lstadd_back();
    test_lstsize();
    test_lstlast();
    test_lstdelone();
    test_lstclear();
    test_lstiter();
    test_lstmap();

    printf("\n%d / %d checks passed\n", g_pass, g_pass + g_fail);
    return (g_fail > 0 ? 1 : 0);
}
RUNNER_EOF
}

# ── checks ────────────────────────────────────────────────────────────────────


check_make() {
    echo
    echo "  check 1/5 — make re"
    make re > "$WORK_DIR/make.log" 2>&1
    if [[ $? -ne 0 ]]; then
        fail "make re"
        echo "         (see $WORK_DIR/make.log)"
        return 1
    fi
    if grep -qi 'warning' "$WORK_DIR/make.log"; then
        fail "make re: build has warnings"
        grep -i 'warning' "$WORK_DIR/make.log" | head -5
        return 1
    fi
    if [[ ! -f libidiot.a ]]; then
        fail "make re: libidiot.a not produced"
        return 1
    fi
    pass "make re"
    return 0
}

check_runner() {
    echo
    echo "  check 2/5 — compile test runner"
    gcc -Wall -Wextra -g -std=c99 \
        _runner.c -L. -lidiot -I. -o _runner \
        > "$WORK_DIR/compile.log" 2>&1
    if [[ $? -ne 0 ]]; then
        fail "compile test runner"
        cat "$WORK_DIR/compile.log"
        return 1
    fi
    pass "compile test runner"
    return 0
}

check_correctness() {
    local summary
    local ec

    echo
    echo "  check 3/5 — correctness"
    ./_runner > "$WORK_DIR/runner.out" 2>&1
    ec=$?

    if grep -q 'FAIL' "$WORK_DIR/runner.out"; then
        grep 'FAIL' "$WORK_DIR/runner.out"
    fi

    summary=$(tail -1 "$WORK_DIR/runner.out")
    [[ -z "$summary" ]] && summary="(no output — runner crashed)"

    if [[ $ec -ne 0 ]]; then
        fail "correctness: $summary"
        return 1
    fi
    pass "correctness: $summary"
    return 0
}

check_valgrind() {
    echo
    echo "  check 4/5 — valgrind"
    valgrind --error-exitcode=1 --leak-check=full --quiet \
        ./_runner > "$WORK_DIR/vg.out" 2> "$WORK_DIR/vg.log"
    if [[ $? -ne 0 ]]; then
        fail "valgrind"
        cat "$WORK_DIR/vg.log"
        return 1
    fi
    pass "valgrind"
    return 0
}

check_sanitisers() {
    local san_flags="-fsanitize=address,undefined"
    local ec

    echo
    echo "  check 5/5 — sanitisers"

    # compile il_*.c directly so instrumentation covers the library code
    gcc -Wall -Wextra -g -std=c99 $san_flags \
        il_*.c _runner.c -I. -o _runner_san \
        > "$WORK_DIR/san_build.log" 2>&1
    if [[ $? -ne 0 ]]; then
        fail "sanitisers: build failed"
        cat "$WORK_DIR/san_build.log"
        return 1
    fi

    ./_runner_san > "$WORK_DIR/san_run.out" 2> "$WORK_DIR/san_run.log"
    ec=$?

    # AddressSanitizer requires overcommit_memory=0 or 1.
    # On systems where vm.overcommit_memory=2 (strict), ASan's shadow mapping
    # fails at startup with a known error. In that case fall back to UBSan only.
    if [[ $ec -ne 0 ]] && grep -q 'ReserveShadowMemoryRange' "$WORK_DIR/san_run.log"; then
        san_flags="-fsanitize=undefined"
        printf "         (ASan shadow mapping unavailable on this system,"
        printf " retrying with UBSan only)\n"
        gcc -Wall -Wextra -g -std=c99 $san_flags \
            il_*.c _runner.c -I. -o _runner_san \
            > "$WORK_DIR/san_build.log" 2>&1
        if [[ $? -ne 0 ]]; then
            fail "sanitisers: build failed"
            cat "$WORK_DIR/san_build.log"
            return 1
        fi
        ./_runner_san > "$WORK_DIR/san_run.out" 2> "$WORK_DIR/san_run.log"
        ec=$?
    fi

    if [[ $ec -ne 0 ]]; then
        fail "sanitisers ($san_flags)"
        cat "$WORK_DIR/san_run.log"
        return 1
    fi
    pass "sanitisers ($san_flags)"
    return 0
}

# ── help ──────────────────────────────────────────────────────────────────────

show_help() {
    cat << 'HELP_EOF'
c01 — The Toolkit / test.sh

Usage: bash test.sh [--help]

Runs 5 checks against your libidiot.a and il_*.c source files.

Checks:
  1. make re       Clean rebuild. libidiot.a must be produced with no warnings.
  2. compile       Links an embedded test runner against libidiot.a.
  3. correctness   Runs the test runner. All checks must pass.
  4. valgrind      Runs the test runner under valgrind. No leaks or errors.
  5. sanitisers    Recompiles il_*.c directly with -fsanitize=address,undefined.
                   Runs the result. No sanitiser errors.

strlcpy, strlcat, and strnstr are tested against embedded reference
implementations — glibc does not include them.
HELP_EOF
}

# ── main ──────────────────────────────────────────────────────────────────────

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    show_help
    exit 0
fi

if [[ $# -gt 0 ]]; then
    echo "error: unknown option: $1" >&2
    echo "usage: bash test.sh [--help]" >&2
    exit 1
fi

banner
preflight
write_runner

check_make || { echo; hr; printf "  make failed — fix build errors before continuing\n"; hr; exit 1; }

check_runner
check_correctness
check_valgrind
check_sanitisers

echo
hr
printf "  %d / %d checks passed\n" "$pass_count" "$((pass_count + fail_count))"
hr

if [[ $fail_count -eq 0 ]]; then
    echo
    printf "  ${C_GREEN}${C_BOLD}All checks passed.${C_RESET}"
    printf " idiotlib is correct, clean, and memory-safe.\n"
    echo "  Every function you wrote — the same logic as the standard library,"
    echo "  written by hand, tested to the same standard."
    echo
    exit 0
else
    echo
    printf "  ${C_RED}%d check(s) failed.${C_RESET}\n" "$fail_count"
    echo
    exit 1
fi
