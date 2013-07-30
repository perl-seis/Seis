#include "pvip.h"
#include "string.h"

int C;

int main() {
    C=0;
    printf("1..1\n");

    PVIPString * x = PVIP_string_new();
    PVIP_string_printf(x, "%s%d", "hoge", 2);

    if (x->len==5 && !memcmp(x->buf, "hoge2", 5)) {
        printf("ok 1\n");
    } else {
        printf("not ok 1\n");
    }
    return 0;
}
