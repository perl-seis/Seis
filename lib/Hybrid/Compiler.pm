package Hybrid::Compiler;
use strict;
use warnings;
use utf8;
use 5.010_001;

use Perl6::PVIP 0.01;
use Carp ();

our $HEADER = <<'...';
use strict;
use autobox 2.79 ARRAY => 'Hybrid::Array';

...

sub new {
    my $class = shift;
    return bless {}, $class;
}

sub compile {
    my ($self, $src) = @_;
    my $parser = Perl6::PVIP->new();
    my $node = $parser->parse_string($src)
        or Hybrid::Exception::ParsingError->throw($parser->errstr);
    return $HEADER . $self->do_compile($node);
}

sub do_compile {
    my ($self, $node) = @_;
    Carp::confess "Invalid node" unless ref $node;

    my $v = $node->value;

    if ($node->type == PVIP_NODE_STATEMENTS) {
        return join(";\n", map { $self->do_compile($_) } @$v);
    } elsif ($node->type == PVIP_NODE_UNDEF) {
        undef;
    } elsif ($node->type == PVIP_NODE_RANGE) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_RANGE is not implemented")
    } elsif ($node->type == PVIP_NODE_REDUCE) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_REDUCE is not implemented")
    } elsif ($node->type == PVIP_NODE_INT) {
        $node->value;
    } elsif ($node->type == PVIP_NODE_NUMBER) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_NUMBER is not implemented")
    } elsif ($node->type == PVIP_NODE_STATEMENTS) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_STATEMENTS is not implemented")
    } elsif ($node->type == PVIP_NODE_DIV) {
        '(' . $self->do_compile($v->[0]) . ')/(' . $self->do_compile($v->[1]) . ')';
    } elsif ($node->type == PVIP_NODE_MUL) {
        '(' . $self->do_compile($v->[0]) . ')*(' . $self->do_compile($v->[1]) . ')';
    } elsif ($node->type == PVIP_NODE_ADD) {
        '(' . $self->do_compile($v->[0]) . ')+(' . $self->do_compile($v->[1]) . ')';
    } elsif ($node->type == PVIP_NODE_SUB) {
        '(' . $self->do_compile($v->[0]) . ')-(' . $self->do_compile($v->[1]) . ')';
    } elsif ($node->type == PVIP_NODE_IDENT) {
        $v;
    } elsif ($node->type == PVIP_NODE_FUNCALL) {
        sprintf('(%s)->(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($node->type == PVIP_NODE_ARGS) {
        join(",", map { $self->do_compile($_) } @$v);
    } elsif ($node->type == PVIP_NODE_STRING) {
        '"' . $v . '"'
    } elsif ($node->type == PVIP_NODE_MOD) {
        sprintf('(%s)%%(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($node->type == PVIP_NODE_VARIABLE) {
        $v;
    } elsif ($node->type == PVIP_NODE_MY) {
        sprintf('my (%s)',
            join(',', map { "($_)" } map { $self->do_compile($_) } @$v)
        );
    } elsif ($node->type == PVIP_NODE_OUR) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_OUR is not implemented")
    } elsif ($node->type == PVIP_NODE_BIND) {
        sprintf('(%s)=(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($node->type == PVIP_NODE_STRING_CONCAT) {
        sprintf('(%s).(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($node->type == PVIP_NODE_IF) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_IF is not implemented")
    } elsif ($node->type == PVIP_NODE_EQV) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_EQV is not implemented")
    } elsif ($node->type == PVIP_NODE_ARRAY) {
        sprintf('[%s]',
            join(',', map { "($_)" } map { $self->do_compile($_) } @$v)
        );
    } elsif ($node->type == PVIP_NODE_ATPOS) {
        if ($v->[0]->type == PVIP_NODE_VARIABLE && $v->[0]->value =~ /\A@/) {
            # @a[0]
            sprintf('(%s)[(%s)]',
                $self->do_compile($v->[0]),
                $self->do_compile($v->[1]),
            );
        } else {
            # $a[0]
            sprintf('(%s)->[(%s)]',
                $self->do_compile($v->[0]),
                $self->do_compile($v->[1]),
            );
        }
    } elsif ($node->type == PVIP_NODE_METHODCALL) {
        sprintf('(%s)->%s',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($node->type == PVIP_NODE_FUNC) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_FUNC is not implemented")
    } elsif ($node->type == PVIP_NODE_PARAMS) {
        # (params (param (nop) (variable "$n") (nop)))
        join(";", map { $self->do_compile($_) } @$v )
    } elsif ($node->type == PVIP_NODE_RETURN) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_RETURN is not implemented")
    } elsif ($node->type == PVIP_NODE_ELSE) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_ELSE is not implemented")
    } elsif ($node->type == PVIP_NODE_WHILE) {
        sprintf("while (%s) { %s }",
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]));
    } elsif ($node->type == PVIP_NODE_DIE) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_DIE is not implemented")
    } elsif ($node->type == PVIP_NODE_ELSIF) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_ELSIF is not implemented")
    } elsif ($node->type == PVIP_NODE_LIST) {
        sprintf('(%s)',
            join(',', map { "($_)" } map { $self->do_compile($_) } @$v)
        );
    } elsif ($node->type == PVIP_NODE_FOR) {
        if ($v->[1]->type == PVIP_NODE_LAMBDA) {
            # (for (list (int 1) (int 2) (int 3)) (lambda (params (param (nop) (variable "$x") (nop))) (statements (inplace_add (variable "$i") (variable "$x")))))
            my $varname = $v->[1]->value->[0]->value->[0]->value->[1]->value;
            sprintf('for my %s (%s) { %s }',
                $varname,
                $self->do_compile($v->[0]),
                $self->do_compile($v->[1]->value->[1])
            );
        } else {
            sprintf('for (%s) { %s }',
                $self->do_compile($v->[0]),
                $self->do_compile($v->[1])
            );
        }
    } elsif ($node->type == PVIP_NODE_UNLESS) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_UNLESS is not implemented")
    } elsif ($node->type == PVIP_NODE_NOT) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_NOT is not implemented")
    } elsif ($node->type == PVIP_NODE_CONDITIONAL) {
        sprintf('(%s)?(%s):(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
            $self->do_compile($v->[2]),
        );
    } elsif ($node->type == PVIP_NODE_NOP) {
        return "();";
    } elsif ($node->type == PVIP_NODE_STREQ) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_STREQ is not implemented")
    } elsif ($node->type == PVIP_NODE_STRNE) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_STRNE is not implemented")
    } elsif ($node->type == PVIP_NODE_STRGT) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_STRGT is not implemented")
    } elsif ($node->type == PVIP_NODE_STRGE) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_STRGE is not implemented")
    } elsif ($node->type == PVIP_NODE_STRLT) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_STRLT is not implemented")
    } elsif ($node->type == PVIP_NODE_STRLE) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_STRLE is not implemented")
    } elsif ($node->type == PVIP_NODE_POW) {
        sprintf('(%s)**(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($node->type == PVIP_NODE_CLARGS) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_CLARGS is not implemented")
    } elsif ($node->type == PVIP_NODE_HASH) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_HASH is not implemented")
    } elsif ($node->type == PVIP_NODE_PAIR) {
        sprintf('(%s)=>(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($node->type == PVIP_NODE_ATKEY) {
        if ($v->[0]->type == PVIP_NODE_VARIABLE && $v->[0]->value =~ /\A%/) {
            my $target = $self->do_compile($v->[0]);
            $target =~ s/\A%/\$/;
            sprintf('%s{(%s)}',
                $target,
                $self->do_compile($v->[1]),
            );
        } else {
            sprintf('(%s){(%s)}',
                $self->do_compile($v->[0]),
                $self->do_compile($v->[1]),
            );
        }
    } elsif ($node->type == PVIP_NODE_LOGICAL_AND) {
        sprintf('(%s)&&(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($node->type == PVIP_NODE_LOGICAL_OR) {
        sprintf('(%s)||(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($node->type == PVIP_NODE_LOGICAL_XOR) {
        sprintf('do { my $a = (%s); my $b = (%s); if ($a) { $b ? !!0 : $a } else { $b ? $b : !!0 } }',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($node->type == PVIP_NODE_BIN_AND) {
        sprintf('(%s)&(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($node->type == PVIP_NODE_BIN_OR) {
        sprintf('(%s)|(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($node->type == PVIP_NODE_BIN_XOR) {
        sprintf('(%s)^(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($node->type == PVIP_NODE_BLOCK) {
        $self->do_compile($v->[0]);
    } elsif ($node->type == PVIP_NODE_LAMBDA) {
        # (lambda (params (param (nop) (variable "$n") (nop))) (statements (mul (variable "$n") (int 2))))
        my $ret = 'sub {';
        $ret .= $self->do_compile($v->[0]);
        $ret .= $self->do_compile($v->[1]);
        $ret .= "}";
        $ret;
    } elsif ($node->type == PVIP_NODE_USE) {
        'use ' . $self->do_compile($v->[0]);
    } elsif ($node->type == PVIP_NODE_MODULE) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_MODULE is not implemented")
    } elsif ($node->type == PVIP_NODE_CLASS) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_CLASS is not implemented")
    } elsif ($node->type == PVIP_NODE_METHOD) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_METHOD is not implemented")
    } elsif ($node->type == PVIP_NODE_UNARY_PLUS) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_UNARY_PLUS is not implemented")
    } elsif ($node->type == PVIP_NODE_UNARY_MINUS) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_UNARY_MINUS is not implemented")
    } elsif ($node->type == PVIP_NODE_IT_METHODCALL) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_IT_METHODCALL is not implemented")
    } elsif ($node->type == PVIP_NODE_LAST) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_LAST is not implemented")
    } elsif ($node->type == PVIP_NODE_NEXT) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_NEXT is not implemented")
    } elsif ($node->type == PVIP_NODE_REDO) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_REDO is not implemented")
    } elsif ($node->type == PVIP_NODE_POSTINC) {
        sprintf('(%s)++',
            $self->do_compile($v->[0]),
        );
    } elsif ($node->type == PVIP_NODE_POSTDEC) {
        sprintf('(%s)--',
            $self->do_compile($v->[0]),
        );
    } elsif ($node->type == PVIP_NODE_PREINC) {
        sprintf('++(%s)',
            $self->do_compile($v->[0]),
        );
    } elsif ($node->type == PVIP_NODE_PREDEC) {
        sprintf('--(%s)',
            $self->do_compile($v->[0]),
        );
    } elsif ($node->type == PVIP_NODE_UNARY_BITWISE_NEGATION) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_UNARY_BITWISE_NEGATION is not implemented")
    } elsif ($node->type == PVIP_NODE_BRSHIFT) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_BRSHIFT is not implemented")
    } elsif ($node->type == PVIP_NODE_BLSHIFT) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_BLSHIFT is not implemented")
    } elsif ($node->type == PVIP_NODE_CHAIN) {
        if (@$v == 1) {
            return $self->do_compile($v->[0]);
        } else {
            my $lhs = $self->do_compile(shift @$v);
            while (my $rhs = shift @$v) {
                if ($rhs->type == PVIP_NODE_EQ) {
                    $lhs = sprintf("(%s)==(%s)", $lhs, $self->do_compile($rhs->value->[0]));
                } elsif ($rhs->type == PVIP_NODE_NE) {
                    $lhs = sprintf("(%s)!=(%s)", $lhs, $self->do_compile($rhs->value->[0]));
                } elsif ($rhs->type == PVIP_NODE_LT) {
                    $lhs = sprintf("(%s)<(%s)", $lhs, $self->do_compile($rhs->value->[0]));
                } elsif ($rhs->type == PVIP_NODE_GT) {
                    $lhs = sprintf("(%s)>(%s)", $lhs, $self->do_compile($rhs->value->[0]));
                } elsif ($rhs->type == PVIP_NODE_GE) {
                    $lhs = sprintf("(%s)>=(%s)", $lhs, $self->do_compile($rhs->value->[0]));
                } elsif ($rhs->type == PVIP_NODE_LE) {
                    $lhs = sprintf("(%s)<=(%s)", $lhs, $self->do_compile($rhs->value->[0]));
                } else {
                    Hybrid::Exception::NotImplemented->throw(sprintf "PVIP_NODE_%s is not implemented in chaning", uc($rhs->name))
                }
            }
            return $lhs;
        }
    } elsif ($node->type == PVIP_NODE_INPLACE_ADD) {
        '(' . $self->do_compile($v->[0]) . ')+=(' . $self->do_compile($v->[1]) . ')';
    } elsif ($node->type == PVIP_NODE_INPLACE_SUB) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_INPLACE_SUB is not implemented")
    } elsif ($node->type == PVIP_NODE_INPLACE_MUL) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_INPLACE_MUL is not implemented")
    } elsif ($node->type == PVIP_NODE_INPLACE_DIV) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_INPLACE_DIV is not implemented")
    } elsif ($node->type == PVIP_NODE_INPLACE_POW) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_INPLACE_POW is not implemented")
    } elsif ($node->type == PVIP_NODE_INPLACE_MOD) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_INPLACE_MOD is not implemented")
    } elsif ($node->type == PVIP_NODE_INPLACE_BIN_OR) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_INPLACE_BIN_OR is not implemented")
    } elsif ($node->type == PVIP_NODE_INPLACE_BIN_AND) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_INPLACE_BIN_AND is not implemented")
    } elsif ($node->type == PVIP_NODE_INPLACE_BIN_XOR) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_INPLACE_BIN_XOR is not implemented")
    } elsif ($node->type == PVIP_NODE_INPLACE_BLSHIFT) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_INPLACE_BLSHIFT is not implemented")
    } elsif ($node->type == PVIP_NODE_INPLACE_BRSHIFT) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_INPLACE_BRSHIFT is not implemented")
    } elsif ($node->type == PVIP_NODE_INPLACE_CONCAT_S) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_INPLACE_CONCAT_S is not implemented")
    } elsif ($node->type == PVIP_NODE_REPEAT_S) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_REPEAT_S is not implemented")
    } elsif ($node->type == PVIP_NODE_INPLACE_REPEAT_S) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_INPLACE_REPEAT_S is not implemented")
    } elsif ($node->type == PVIP_NODE_UNARY_TILDE) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_UNARY_TILDE is not implemented")
    } elsif ($node->type == PVIP_NODE_TRY) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_TRY is not implemented")
    } elsif ($node->type == PVIP_NODE_REF) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_REF is not implemented")
    } elsif ($node->type == PVIP_NODE_MULTI) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_MULTI is not implemented")
    } elsif ($node->type == PVIP_NODE_LANG) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_LANG is not implemented")
    } elsif ($node->type == PVIP_NODE_UNARY_BOOLEAN) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_UNARY_BOOLEAN is not implemented")
    } elsif ($node->type == PVIP_NODE_UNARY_UPTO) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_UNARY_UPTO is not implemented")
    } elsif ($node->type == PVIP_NODE_STDOUT) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_STDOUT is not implemented")
    } elsif ($node->type == PVIP_NODE_STDERR) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_STDERR is not implemented")
    } elsif ($node->type == PVIP_NODE_INFINITY) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_INFINITY is not implemented")
    } elsif ($node->type == PVIP_NODE_SCALAR_DEREF) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_SCALAR_DEREF is not implemented")
    } elsif ($node->type == PVIP_NODE_TW_INC) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_TW_INC is not implemented")
    } elsif ($node->type == PVIP_NODE_META_METHOD_CALL) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_META_METHOD_CALL is not implemented")
    } elsif ($node->type == PVIP_NODE_REGEXP) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_REGEXP is not implemented")
    } elsif ($node->type == PVIP_NODE_SMART_MATCH) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_SMART_MATCH is not implemented")
    } elsif ($node->type == PVIP_NODE_NOT_SMART_MATCH) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_NOT_SMART_MATCH is not implemented")
    } elsif ($node->type == PVIP_NODE_PERL5_REGEXP) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_PERL5_REGEXP is not implemented")
    } elsif ($node->type == PVIP_NODE_TRUE) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_TRUE is not implemented")
    } elsif ($node->type == PVIP_NODE_TW_VM) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_TW_VM is not implemented")
    } elsif ($node->type == PVIP_NODE_HAS) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_HAS is not implemented")
    } elsif ($node->type == PVIP_NODE_PRIVATE_ATTRIBUTE) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_PRIVATE_ATTRIBUTE is not implemented")
    } elsif ($node->type == PVIP_NODE_PUBLIC_ATTRIBUTE) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_PUBLIC_ATTRIBUTE is not implemented")
    } elsif ($node->type == PVIP_NODE_FUNCREF) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_FUNCREF is not implemented")
    } elsif ($node->type == PVIP_NODE_PATH) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_PATH is not implemented")
    } elsif ($node->type == PVIP_NODE_TW_PACKAGE) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_TW_PACKAGE is not implemented")
    } elsif ($node->type == PVIP_NODE_TW_CLASS) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_TW_CLASS is not implemented")
    } elsif ($node->type == PVIP_NODE_TW_MODULE) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_TW_MODULE is not implemented")
    } elsif ($node->type == PVIP_NODE_TW_OS) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_TW_OS is not implemented")
    } elsif ($node->type == PVIP_NODE_TW_PID) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_TW_PID is not implemented")
    } elsif ($node->type == PVIP_NODE_TW_PERLVER) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_TW_PERLVER is not implemented")
    } elsif ($node->type == PVIP_NODE_TW_OSVER) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_TW_OSVER is not implemented")
    } elsif ($node->type == PVIP_NODE_TW_CWD) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_TW_CWD is not implemented")
    } elsif ($node->type == PVIP_NODE_TW_EXECUTABLE_NAME) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_TW_EXECUTABLE_NAME is not implemented")
    } elsif ($node->type == PVIP_NODE_TW_ROUTINE) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_TW_ROUTINE is not implemented")
    } elsif ($node->type == PVIP_NODE_SLANGS) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_SLANGS is not implemented")
    } elsif ($node->type == PVIP_NODE_LOGICAL_ANDTHEN) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_LOGICAL_ANDTHEN is not implemented")
    } elsif ($node->type == PVIP_NODE_VALUE_IDENTITY) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_VALUE_IDENTITY is not implemented")
    } elsif ($node->type == PVIP_NODE_CMP) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_CMP is not implemented")
    } elsif ($node->type == PVIP_NODE_SPECIAL_VARIABLE_REGEXP_MATCH) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_SPECIAL_VARIABLE_REGEXP_MATCH is not implemented")
    } elsif ($node->type == PVIP_NODE_SPECIAL_VARIABLE_EXCEPTIONS) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_SPECIAL_VARIABLE_EXCEPTIONS is not implemented")
    } elsif ($node->type == PVIP_NODE_ENUM) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_ENUM is not implemented")
    } elsif ($node->type == PVIP_NODE_NUM_CMP) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_NUM_CMP is not implemented")
    } elsif ($node->type == PVIP_NODE_UNARY_FLATTEN_OBJECT) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_UNARY_FLATTEN_OBJECT is not implemented")
    } elsif ($node->type == PVIP_NODE_COMPLEX) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_COMPLEX is not implemented")
    } elsif ($node->type == PVIP_NODE_ROLE) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_ROLE is not implemented")
    } elsif ($node->type == PVIP_NODE_IS) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_IS is not implemented")
    } elsif ($node->type == PVIP_NODE_DOES) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_DOES is not implemented")
    } elsif ($node->type == PVIP_NODE_JUNCTIVE_AND) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_JUNCTIVE_AND is not implemented")
    } elsif ($node->type == PVIP_NODE_JUNCTIVE_SAND) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_JUNCTIVE_SAND is not implemented")
    } elsif ($node->type == PVIP_NODE_JUNCTIVE_OR) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_JUNCTIVE_OR is not implemented")
    } elsif ($node->type == PVIP_NODE_UNICODE_CHAR) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_UNICODE_CHAR is not implemented")
    } elsif ($node->type == PVIP_NODE_STUB) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_STUB is not implemented")
    } elsif ($node->type == PVIP_NODE_EXPORTABLE) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_EXPORTABLE is not implemented")
    } elsif ($node->type == PVIP_NODE_PARAM) {
        # (params (param (nop) (variable "$n") (nop)))
        sprintf('my %s=shift;', $self->do_compile($v->[1]));
    } elsif ($node->type == PVIP_NODE_BITWISE_OR) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_BITWISE_OR is not implemented")
    } elsif ($node->type == PVIP_NODE_BITWISE_AND) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_BITWISE_AND is not implemented")
    } elsif ($node->type == PVIP_NODE_BITWISE_XOR) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_BITWISE_XOR is not implemented")
    } elsif ($node->type == PVIP_NODE_VARGS) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_VARGS is not implemented")
    } elsif ($node->type == PVIP_NODE_WHATEVER) {
        Hybrid::Exception::NotImplemented->throw("PVIP_NODE_WHATEVER is not implemented")
    } else {
        Hybrid::Exception::UnknownNode->throw(
             ("Unknown node: PVIP_NODE_" . uc($node->name))
        );
    }
}



1;

