#ifndef PVIP_H_
#define PVIP_H_

#include <stdint.h>
#include <stdio.h>
#include <stdarg.h>

#ifdef __cplusplus
extern "C" {
#endif

#define PVIP_FALSE 0
#define PVIP_TRUE  1

typedef int PVIP_BOOL;

typedef enum {
    PVIP_NODE_UNDEF,
    PVIP_NODE_RANGE,
    PVIP_NODE_REDUCE,
    PVIP_NODE_INT,
    PVIP_NODE_NUMBER,
    PVIP_NODE_STATEMENTS,
    PVIP_NODE_DIV,
    PVIP_NODE_MUL,
    PVIP_NODE_ADD,
    PVIP_NODE_SUB,
    PVIP_NODE_IDENT,
    PVIP_NODE_FUNCALL,
    PVIP_NODE_ARGS,
    PVIP_NODE_STRING,
    PVIP_NODE_MOD,
    PVIP_NODE_VARIABLE,
    PVIP_NODE_MY,
    PVIP_NODE_OUR,
    PVIP_NODE_BIND,
    PVIP_NODE_STRING_CONCAT,
    PVIP_NODE_IF,
    PVIP_NODE_EQV,
    PVIP_NODE_EQ,
    PVIP_NODE_NE,
    PVIP_NODE_LT,
    PVIP_NODE_LE,
    PVIP_NODE_GT,
    PVIP_NODE_GE,
    PVIP_NODE_ARRAY,
    PVIP_NODE_ATPOS,
    PVIP_NODE_METHODCALL,
    PVIP_NODE_FUNC,
    PVIP_NODE_PARAMS,
    PVIP_NODE_RETURN,
    PVIP_NODE_ELSE,
    PVIP_NODE_WHILE,
    PVIP_NODE_DIE,
    PVIP_NODE_ELSIF,
    PVIP_NODE_LIST,
    PVIP_NODE_FOR,
    PVIP_NODE_UNLESS,
    PVIP_NODE_NOT,
    PVIP_NODE_CONDITIONAL,
    PVIP_NODE_NOP,
    PVIP_NODE_STREQ,
    PVIP_NODE_STRNE,
    PVIP_NODE_STRGT,
    PVIP_NODE_STRGE,
    PVIP_NODE_STRLT,
    PVIP_NODE_STRLE,
    PVIP_NODE_POW,
    PVIP_NODE_CLARGS,
    PVIP_NODE_HASH,
    PVIP_NODE_PAIR,
    PVIP_NODE_ATKEY,
    PVIP_NODE_LOGICAL_AND,
    PVIP_NODE_LOGICAL_OR,
    PVIP_NODE_LOGICAL_XOR,
    PVIP_NODE_BIN_AND,
    PVIP_NODE_BIN_OR,
    PVIP_NODE_BIN_XOR,
    PVIP_NODE_BLOCK,
    PVIP_NODE_LAMBDA,
    PVIP_NODE_USE,
    PVIP_NODE_MODULE,
    PVIP_NODE_CLASS,
    PVIP_NODE_METHOD,
    PVIP_NODE_UNARY_PLUS,
    PVIP_NODE_UNARY_MINUS,
    PVIP_NODE_IT_METHODCALL,
    PVIP_NODE_LAST,
    PVIP_NODE_NEXT,
    PVIP_NODE_REDO,
    PVIP_NODE_POSTINC,
    PVIP_NODE_POSTDEC,
    PVIP_NODE_PREINC,
    PVIP_NODE_PREDEC,
    PVIP_NODE_UNARY_BITWISE_NEGATION,
    PVIP_NODE_BRSHIFT,
    PVIP_NODE_BLSHIFT,
    PVIP_NODE_CHAIN,
    PVIP_NODE_INPLACE_ADD,
    PVIP_NODE_INPLACE_SUB,
    PVIP_NODE_INPLACE_MUL,
    PVIP_NODE_INPLACE_DIV,
    PVIP_NODE_INPLACE_POW,
    PVIP_NODE_INPLACE_MOD,
    PVIP_NODE_INPLACE_BIN_OR,
    PVIP_NODE_INPLACE_BIN_AND,
    PVIP_NODE_INPLACE_BIN_XOR,
    PVIP_NODE_INPLACE_BLSHIFT,
    PVIP_NODE_INPLACE_BRSHIFT,
    PVIP_NODE_INPLACE_CONCAT_S,
    PVIP_NODE_REPEAT_S,
    PVIP_NODE_INPLACE_REPEAT_S,
    PVIP_NODE_UNARY_TILDE,
    PVIP_NODE_TRY,
    PVIP_NODE_REF,
    PVIP_NODE_MULTI,
    PVIP_NODE_LANG,
    PVIP_NODE_UNARY_BOOLEAN, /* ? */
    PVIP_NODE_UNARY_UPTO, /* ^ */
    PVIP_NODE_STDOUT, /* $*OUT */
    PVIP_NODE_STDERR, /* $*ERR */
    PVIP_NODE_SCALAR_DEREF, /* $$var */
    PVIP_NODE_TW_INC, /* @*INC */
    PVIP_NODE_META_METHOD_CALL, /* $foo.^methods */
    PVIP_NODE_REGEXP,
    PVIP_NODE_SMART_MATCH, /* ~~ */
    PVIP_NODE_NOT_SMART_MATCH, /* !~~ */
    PVIP_NODE_PERL5_REGEXP, /* m:P5/./ */
    PVIP_NODE_TRUE,
    PVIP_NODE_TW_VM,  /* $*VM */
    PVIP_NODE_HAS,
    PVIP_NODE_PRIVATE_ATTRIBUTE, /* $.var */
    PVIP_NODE_PUBLIC_ATTRIBUTE,  /* $!var */
    PVIP_NODE_FUNCREF,           /* &var */
    PVIP_NODE_PATH, /* qp{}, IO::Path literal */
    PVIP_NODE_TW_PACKAGE, /* $?PACKAGE */
    PVIP_NODE_TW_CLASS, /* $?CLASS */
    PVIP_NODE_TW_MODULE, /* $?MODULE */
    PVIP_NODE_TW_OS, /* $*OS */
    PVIP_NODE_TW_PID, /* $*PID */
    PVIP_NODE_TW_PERLVER, /* $*PPERLVER */
    PVIP_NODE_TW_OSVER, /* $*OSVER */
    PVIP_NODE_TW_CWD, /* $*CWD */
    PVIP_NODE_TW_EXECUTABLE_NAME, /* $*EXECUTABLE_NAME */
    PVIP_NODE_TW_ROUTINE, /* &?ROUTINE */
    PVIP_NODE_SLANGS, /* $~MAIN */
    PVIP_NODE_LOGICAL_ANDTHEN, /* andthen operator */
    PVIP_NODE_VALUE_IDENTITY, /* '===' operator in S03-operators/value_equivalence.t */
    PVIP_NODE_CMP, /* 'cmp' operator */
    PVIP_NODE_SPECIAL_VARIABLE_REGEXP_MATCH, /* $/ - regex match */
    PVIP_NODE_SPECIAL_VARIABLE_EXCEPTIONS, /* $! - exceptions */
    PVIP_NODE_ENUM,
    PVIP_NODE_NUM_CMP, /* <=> */
    PVIP_NODE_UNARY_FLATTEN_OBJECT, /* unary | */
    PVIP_NODE_COMPLEX, /* 2i */
    PVIP_NODE_ROLE,
    PVIP_NODE_IS,
    PVIP_NODE_DOES,
    PVIP_NODE_JUNCTIVE_AND, /* & */
    PVIP_NODE_JUNCTIVE_SAND, /* S& */
    PVIP_NODE_JUNCTIVE_OR, /* | */
    PVIP_NODE_UNICODE_CHAR, /* \c[] */
    PVIP_NODE_STUB, /* ... */
    PVIP_NODE_EXPORTABLE, /* is exportable */
    PVIP_NODE_PARAM,
    PVIP_NODE_BITWISE_OR,  /* ~| */
    PVIP_NODE_BITWISE_AND, /* ~& */
    PVIP_NODE_BITWISE_XOR, /* ~^ */
    PVIP_NODE_VARGS, /* sub foo (*@a) { } */
    PVIP_NODE_WHATEVER, /* * */
    PVIP_NODE_TW_ENV, /* %*ENV */
    PVIP_NODE_ARRAY_DEREF, /* @$v */
    PVIP_NODE_RAND, /* rand */
    PVIP_NODE_END, /* END { } */
} PVIP_node_type_t;

typedef enum {
    PVIP_CATEGORY_UNKNOWN,
    PVIP_CATEGORY_STRING,
    PVIP_CATEGORY_INT,
    PVIP_CATEGORY_NUMBER,
    PVIP_CATEGORY_CHILDREN
} PVIP_category_t;

typedef struct {
    char *buf;
    size_t len;
    size_t buflen;
} PVIPString;

typedef struct _PVIPNode {
    PVIP_node_type_t type;
    union {
        int64_t iv;
        double nv;
        PVIPString *pv;
        struct {
            int size;
            struct _PVIPNode **nodes;
        } children;
    };
} PVIPNode;

/* parser related public apis */
PVIPNode * PVIP_parse_string(const char *string, int len, int debug, PVIPString **error);
PVIPNode * PVIP_parse_fp(FILE *fp, int debug, PVIPString **error);


/* node related public apis */
void PVIP_node_destroy(PVIPNode *node);
const char* PVIP_node_name(PVIP_node_type_t t);
PVIP_category_t PVIP_node_category(PVIP_node_type_t type);
void PVIP_node_as_sexp(PVIPNode * node, PVIPString *buf);

/* node */
PVIPNode* PVIP_node_new_children(PVIP_node_type_t type);
PVIPNode* PVIP_node_new_children1(PVIP_node_type_t type, PVIPNode* n1);
PVIPNode* PVIP_node_new_children2(PVIP_node_type_t type, PVIPNode* n1, PVIPNode *n2);
PVIPNode* PVIP_node_new_children3(PVIP_node_type_t type, PVIPNode* n1, PVIPNode *n2, PVIPNode *n3);
PVIPNode* PVIP_node_new_children4(PVIP_node_type_t type, PVIPNode* n1, PVIPNode *n2, PVIPNode *n3, PVIPNode *n4);
PVIPNode* PVIP_node_new_int(PVIP_node_type_t type, int64_t n);
PVIPNode* PVIP_node_new_intf(PVIP_node_type_t type, const char *str, size_t len, int base);
PVIPNode* PVIP_node_new_string(PVIP_node_type_t type, const char* str, size_t len);
PVIPNode* PVIP_node_new_number(PVIP_node_type_t type, const char *str, size_t len);

void PVIP_node_push_child(PVIPNode* node, PVIPNode* child);

PVIPNode* PVIP_node_append_string(PVIPNode *node, const char* str, size_t len);
PVIPNode* PVIP_node_append_string_from_hex(PVIPNode * node, const char *str, size_t len);
PVIPNode* PVIP_node_append_string_from_oct(PVIPNode * node, const char *str, size_t len);
PVIPNode* PVIP_node_append_string_from_dec(PVIPNode * node, const char *str, size_t len);
PVIPNode* PVIP_node_append_string_node(PVIPNode*node, PVIPNode*stuff);

void PVIP_node_change_type(PVIPNode *node, PVIP_node_type_t type);

void PVIP_node_dump_sexp(PVIPNode * node);


/* string */
PVIPString *PVIP_string_new();
void PVIP_string_destroy(PVIPString *str);
PVIP_BOOL PVIP_string_concat(PVIPString *str, const char *src, size_t len);
PVIP_BOOL PVIP_string_concat_int(PVIPString *str, int64_t n);
PVIP_BOOL PVIP_string_concat_number(PVIPString *str, double n);
PVIP_BOOL PVIP_string_concat_char(PVIPString *str, char n);
void PVIP_string_say(PVIPString *str);
PVIP_BOOL PVIP_string_vprintf(PVIPString *str, const char*format, va_list ap);
PVIP_BOOL PVIP_string_printf(PVIPString *str, const char*format, ...);
const char * PVIP_string_c_str(PVIPString *str);

#ifdef __cplusplus
};
#endif

#endif /* PVIP_H_ */
