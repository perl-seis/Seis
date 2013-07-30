#include <stdlib.h>
#include <inttypes.h>
#include <string.h>
#include <assert.h>
#include <stdio.h>
#include "pvip.h"

PVIPString *PVIP_string_new() {
    PVIPString *str = malloc(sizeof(PVIPString));
    memset(str, 0, sizeof(PVIPString));
    assert(str);
    str->len    = 0;
    str->buflen = 1024;
    str->buf    = malloc(str->buflen);
    return str;
}

void PVIP_string_destroy(PVIPString *str) {
    free(str->buf);
    str->buf = NULL;
    free(str);
}

void PVIP_string_concat(PVIPString *str, const char *src, size_t len) {
    if (str->len + len > str->buflen) {
        str->buflen = ( str->len + len ) * 2;
        str->buf    = realloc(str->buf, str->buflen);
    }
    memcpy(str->buf + str->len, src, len);
    str->len += len;
}

void PVIP_string_concat_int(PVIPString *str, int64_t n) {
    char buf[1024];
    int res = snprintf(buf, 1023, "%" PRIi64, n);
    PVIP_string_concat(str, buf, res);
}

void PVIP_string_concat_number(PVIPString *str, double n) {
    char buf[1024];
    int res = snprintf(buf, 1023, "%f", n);
    for (; res>1; --res) { /* remove trailing zeros */
        if (buf[res-1]!='0') {
            break;
        }
    }
    PVIP_string_concat(str, buf, res);
}

void PVIP_string_concat_char(PVIPString *str, char c) {
    PVIP_string_concat(str, &c, 1);
}

void PVIP_string_say(PVIPString *str) {
    fwrite(str->buf, 1, str->len, stdout);
    fwrite("\n", 1, 1, stdout);
}

