package Rokugo::Compiler;
use strict;
use warnings;
use utf8;
use 5.010_001;

use Perl6::PVIP 0.01;
use Carp ();
use Rokugo::Object;
use Rokugo::Array;
use Rokugo::Int;
use Rokugo::Real;
use Rokugo::Exceptions;
use Rokugo::Str;
use Rokugo::Hash;
use Rokugo::MetaClass;
use Data::Dumper ();
use Encode ();
use boolean ();

use constant {
    G_VOID => 1,
    G_SCALAR => 2,
};

# `no warnings 'misc'` suppress `"our" variable $x redeclared` message
# in `our $x; { my $x; { our $x}}`
our $HEADER = <<'...';
package main;
use strict;
use 5.014_001;
use autobox 2.79 ARRAY => 'Rokugo::Array', INTEGER => 'Rokugo::Int', 'FLOAT' => 'Rokugo::Real', 'STRING' => 'Rokugo::Str', HASH => 'Rokugo::Hash';
use List::Util qw(min max);
use Rokugo::MetaClass;
use Rokugo::Class;
no warnings 'misc', 'void';

...

sub new {
    my $class = shift;
    return bless {}, $class;
}

sub compile {
    my ($self, $src, $filename) = @_;
    $filename //= '-e';
    local $self->{filename} = $filename;
    my $parser = Perl6::PVIP->new();
    my $node = $parser->parse_string($src)
        or Rokugo::Exception::ParsingError->throw($parser->errstr);
    return join('',
        $HEADER,
        qq{#line 1 "$filename"\n},
        $self->do_compile($node)
    );
}

sub do_compile {
    my ($self, $node, $gimme) = @_;
    $gimme //= G_SCALAR;
    Carp::confess "Invalid node" unless ref $node;

    my $v = $node->value;
    my $type = $node->type;

    if ($type == PVIP_NODE_STATEMENTS) {
        my @ret;
        for (my $i=0; $i<@$v; $i++) {
            next if $v->[$i]->type == PVIP_NODE_NOP;
            push @ret, $self->do_compile($v->[$i], $i==@$v-1 ? G_SCALAR : G_VOID);
        }
        return join(";\n", @ret);
    } elsif ($type == PVIP_NODE_UNDEF) {
        undef;
    } elsif ($type == PVIP_NODE_RANGE) {
        $self->do_compile($v->[0]) . '..' . $self->do_compile($v->[1]);
    } elsif ($type == PVIP_NODE_REDUCE) {
        my $body;
        if ($v->[0]->value =~ /[a-z]/) {
            $body = sprintf '$rokugo_reduce_ret = %s($rokugo_reduce_ret, $rokugo_reduce_stuff)', $v->[0]->value;
        } else {
            $body = sprintf '$rokugo_reduce_ret %s= $rokugo_reduce_stuff', $v->[0]->value;
        }
        sprintf('do { my @rokugo_reduce_ary = %s; my $rokugo_reduce_ret = shift @rokugo_reduce_ary; for my $rokugo_reduce_stuff (@rokugo_reduce_ary) { %s } $rokugo_reduce_ret; }', $self->do_compile($v->[1]), $body);
    } elsif ($type == PVIP_NODE_INT) {
        $node->value;
    } elsif ($type == PVIP_NODE_NUMBER) {
        $node->value;
    } elsif ($type == PVIP_NODE_DIV) {
        '(' . $self->do_compile($v->[0]) . ')/(' . $self->do_compile($v->[1]) . ')';
    } elsif ($type == PVIP_NODE_MUL) {
        '(' . $self->do_compile($v->[0]) . ')*(' . $self->do_compile($v->[1]) . ')';
    } elsif ($type == PVIP_NODE_ADD) {
        '(' . $self->do_compile($v->[0]) . ')+(' . $self->do_compile($v->[1]) . ')';
    } elsif ($type == PVIP_NODE_SUB) {
        '(' . $self->do_compile($v->[0]) . ')-(' . $self->do_compile($v->[1]) . ')';
    } elsif ($type == PVIP_NODE_IDENT) {
        $v;
    } elsif ($type == PVIP_NODE_FUNCALL) {
        if ($v->[0]->type == PVIP_NODE_IDENT) {
            if ($v->[0]->value eq 'shift' || $v->[0]->value eq 'pop') {
                # shift(@array)
                local $self->{args_list} = 1;
                sprintf('%s(%s)',
                    $self->do_compile($v->[0]),
                    $self->do_compile($v->[1]),
                );
            } else {
                sprintf('%s(%s)',
                    $self->do_compile($v->[0]),
                    $self->do_compile($v->[1]),
                );
            }
        } else {
            sprintf('(%s)->(%s)',
                $self->do_compile($v->[0]),
                $self->do_compile($v->[1]),
            );
        }
    } elsif ($type == PVIP_NODE_ARGS) {
        my @args = map {
            ($_->type == PVIP_NODE_IDENT && $_->value eq 'Bool')
                ? 'boolean::'
                : $self->do_compile($_)
        } @$v;
        if ($self->{args_list}) {
            join(",", map { "$_" } @args);
        } else {
            join(",", map { "scalar($_)" } @args);
        }
    } elsif ($type == PVIP_NODE_STRING) {
        local $Data::Dumper::Terse = 1;
        local $Data::Dumper::Useqq = 1;
        local $Data::Dumper::Purity = 1;
        local $Data::Dumper::Indent = 0;
        Data::Dumper::Dumper(Encode::decode_utf8($v));
    } elsif ($type == PVIP_NODE_MOD) {
        sprintf('(%s)%%(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($type == PVIP_NODE_VARIABLE) {
        $v;
    } elsif ($type == PVIP_NODE_MY) {
        sprintf('my (%s)',
            join(',', map { "($_)" } map { $self->do_compile($_) } @$v)
        );
    } elsif ($type == PVIP_NODE_OUR) {
        my @vars = map { $self->do_compile($_) } @$v;
        sprintf('our (%s)',
            join(',', map { "($_)" } @vars)
        );
    } elsif ($type == PVIP_NODE_BIND) {
        sprintf('%s=(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($type == PVIP_NODE_STRING_CONCAT) {
        sprintf('(%s).(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($type == PVIP_NODE_IF) {
        # (if (int 1) (statements (int 5)) (else (int 4)))
        my $ret = 'if (' . $self->do_compile($v->[0]) . ') {' . $self->do_compile($v->[1]) . '}';
        shift @$v; shift @$v;
        while (@$v) {
            $ret .= $self->do_compile(shift @$v);
        }
        $ret;
    } elsif ($type == PVIP_NODE_EQV) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_EQV is not implemented")
    } elsif ($type == PVIP_NODE_ARRAY) {
        sprintf('[%s]',
            join(',', map { "($_)" } map { $self->do_compile($_) } @$v)
        );
    } elsif ($type == PVIP_NODE_ATPOS) {
        if (
            ($v->[0]->type == PVIP_NODE_VARIABLE && $v->[0]->value =~ /\A@/)
            || $v->[0]->type == PVIP_NODE_RANGE
        ) {
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
    } elsif ($type == PVIP_NODE_METHODCALL) {
        my $invocant = $self->do_compile($v->[0]);
        my $method = $self->do_compile($v->[1]);
        my $params = defined($v->[2]) ? $self->do_compile($v->[2]) : '';
        if ($v->[0]->type == PVIP_NODE_LIST) {
            # (8,6,9).elems
            sprintf('Rokugo::Array::%s([%s], %s)',
                $method,
                $invocant,
                $params,
            );
        } else {
            sprintf('(%s)->%s(%s)',
                $invocant,
                $method,
                $params,
            );
        }
    } elsif ($type == PVIP_NODE_FUNC) {
        my $ret = 'sub ';
        $ret .= $self->do_compile($v->[0]);
        $ret .= " {\n";
        $ret .= $self->do_compile($v->[1]);
        $ret .= $self->do_compile($v->[3]);
        $ret .= "}\n";
        $ret;
    } elsif ($type == PVIP_NODE_PARAMS) {
        # (params (param (nop) (variable "$n") (nop)))
        join(";", map { $self->do_compile($_) } @$v ) . ";undef;"
    } elsif ($type == PVIP_NODE_RETURN) {
        'return (' . join(',', map { "($_)" } map {$self->do_compile($_)} @$v) . ')';
    } elsif ($type == PVIP_NODE_ELSE) {
        'else { ' . $self->do_compile($v->[0]) . '}';
    } elsif ($type == PVIP_NODE_WHILE) {
        sprintf("while (%s) %s",
            $self->do_compile($v->[0]),
            $self->maybe_block($v->[1]));
    } elsif ($type == PVIP_NODE_DIE) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_DIE is not implemented")
    } elsif ($type == PVIP_NODE_ELSIF) {
        sprintf('elsif (%s) { %s }', $self->do_compile($v->[0]), $self->do_compile($v->[1]));
    } elsif ($type == PVIP_NODE_LIST) {
        sprintf('(%s)',
            join(',', map { "($_)" } map { $self->do_compile($_) } @$v)
        );
    } elsif ($type == PVIP_NODE_FOR) {
        if ($v->[1]->type == PVIP_NODE_LAMBDA) {
            # (for (list (int 1) (int 2) (int 3)) (lambda (params (param (nop) (variable "$x") (nop))) (statements (inplace_add (variable "$i") (variable "$x")))))
            my $varname = $v->[1]->value->[0]->value->[0]->value->[1]->value;
            sprintf('for my %s (%s) %s',
                $varname,
                $self->do_compile($v->[0]),
                $self->maybe_block($v->[1]->value->[1])
            );
        } else {
            sprintf('for (%s) %s',
                $self->do_compile($v->[0]),
                $self->maybe_block($v->[1])
            );
        }
    } elsif ($type == PVIP_NODE_UNLESS) {
        my $ret = 'unless (' . $self->do_compile($v->[0]) . ') {' . $self->do_compile($v->[1]) . '}';
        shift @$v; shift @$v;
        while (@$v) {
            $ret .= $self->do_compile(shift @$v);
        }
        $ret;
    } elsif ($type == PVIP_NODE_NOT) {
        sprintf('!(%s)',
            $self->do_compile($v->[0])
        );
    } elsif ($type == PVIP_NODE_CONDITIONAL) {
        sprintf('(%s)?(%s):(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
            $self->do_compile($v->[2]),
        );
    } elsif ($type == PVIP_NODE_NOP) {
        return "()";
    } elsif ($type == PVIP_NODE_POW) {
        sprintf('(%s)**(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($type == PVIP_NODE_CLARGS) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_CLARGS is not implemented")
    } elsif ($type == PVIP_NODE_HASH) {
        '{' . join(',', map { $self->do_compile($_) } @$v) . '}';
    } elsif ($type == PVIP_NODE_PAIR) {
        sprintf('(%s)=>scalar(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($type == PVIP_NODE_ATKEY) {
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
    } elsif ($type == PVIP_NODE_LOGICAL_AND) {
        sprintf('(%s)&&(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($type == PVIP_NODE_LOGICAL_OR) {
        sprintf('(%s)||(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($type == PVIP_NODE_LOGICAL_XOR) {
        sprintf('do { my $a = (%s); my $b = (%s); if ($a) { $b ? !!0 : $a } else { $b ? $b : !!0 } }',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($type == PVIP_NODE_BIN_AND) {
        sprintf('(%s)&(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($type == PVIP_NODE_BIN_OR) {
        sprintf('(%s)|(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($type == PVIP_NODE_BIN_XOR) {
        sprintf('(%s)^(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($type == PVIP_NODE_BLOCK) {
        if (@$v) {
            '{' . $self->do_compile($v->[0]) . '}';
        } else {
            '{ }';
        }
    } elsif ($type == PVIP_NODE_LAMBDA) {
        # (lambda (params (param (nop) (variable "$n") (nop))) (statements (mul (variable "$n") (int 2))))
        my $ret = 'sub {';
        $ret .= $self->do_compile($v->[0]);
        $ret .= $self->do_compile($v->[1]);
        $ret .= "}";
        $ret;
    } elsif ($type == PVIP_NODE_USE) {
        if ($v->[0]->value eq 'v6') {
            "# use v6\n";
        } else {
            'use ' . $self->do_compile($v->[0]);
        }
    } elsif ($type == PVIP_NODE_MODULE) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_MODULE is not implemented")
    } elsif ($type == PVIP_NODE_CLASS) {
        # (class (ident "Foo7") (nop) (statements (method (ident "bar") (nop) (statements (int 5963)))))
        # (class (ident "Foo8") (list (is (ident "Foo7"))) (statements))
        state $ANON_CLASS = 0;
        my $pkg = $v->[0]->type == PVIP_NODE_NOP ? "Rokugo::_AnonClass" . $ANON_CLASS++ : $self->do_compile($v->[0]);
        my $retval = $gimme == G_VOID ? '' : "Rokugo::Class->new(name => '$pkg')";
        my $body = $self->do_compile($v->[2]);
        if ($body eq '{ }') {
            $body = '';
        }
        sprintf(q!do {
            package %s;
            BEGIN {
                our @ISA;
                unshift @ISA, "Rokugo::Object";
                %s;
            }
            %s;
            %s
        }!, $pkg, join(";\n", map { $self->do_compile($_) } @{$v->[1]->value}), $body, $retval);
    } elsif ($type == PVIP_NODE_METHOD) {
        # (method (ident "bar") (nop) (statements))
        # TODO: support arguments
        # (method (ident "bar") (params (param (nop) (variable "$n") (nop))) (statements (mul (variable "$n") (int 3))))
        join('',
            'sub ' . $self->do_compile($v->[0]) . ' {',
            'my $self=shift;',
            (map { 'my ' . $self->do_compile($_->value->[1]) . ' = shift;' } @{$v->[1]->value}),
            'undef;',
            $self->do_compile($v->[2]),
            ';}'
        );
    } elsif ($type == PVIP_NODE_UNARY_PLUS) {
        sprintf('+(%s)', $self->do_compile($v->[0]));
    } elsif ($type == PVIP_NODE_UNARY_MINUS) {
        sprintf('-(%s)', $self->do_compile($v->[0]));
    } elsif ($type == PVIP_NODE_IT_METHODCALL) {
        sprintf('$_->%s(%s)',
            $self->do_compile($v->[0]),
            defined($v->[1]) ? $self->do_compile($v->[1]) : '',
        );
    } elsif ($type == PVIP_NODE_LAST) {
        'last';
    } elsif ($type == PVIP_NODE_NEXT) {
        'next';
    } elsif ($type == PVIP_NODE_REDO) {
        'redo';
    } elsif ($type == PVIP_NODE_POSTINC) {
        sprintf('(%s)++',
            $self->do_compile($v->[0]),
        );
    } elsif ($type == PVIP_NODE_POSTDEC) {
        sprintf('(%s)--',
            $self->do_compile($v->[0]),
        );
    } elsif ($type == PVIP_NODE_PREINC) {
        sprintf('++(%s)',
            $self->do_compile($v->[0]),
        );
    } elsif ($type == PVIP_NODE_PREDEC) {
        sprintf('--(%s)',
            $self->do_compile($v->[0]),
        );
    } elsif ($type == PVIP_NODE_UNARY_BITWISE_NEGATION) {
        sprintf('~(%s)',
            $self->do_compile($v->[0]),
        );
    } elsif ($type == PVIP_NODE_BRSHIFT) {
        sprintf('(%s)>>(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($type == PVIP_NODE_BLSHIFT) {
        sprintf('(%s)<<(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($type == PVIP_NODE_CHAIN) {
        my $compile = sub {
            my ($lhs, $type, $rhs) = @_; 
            my $op = +{
                PVIP_NODE_EQ() => '==',
                PVIP_NODE_NE() => '!=',
                PVIP_NODE_LT() => '<',
                PVIP_NODE_LE() => '<=',
                PVIP_NODE_GT() => '>',
                PVIP_NODE_GE() => '>=',
                PVIP_NODE_STREQ() => 'eq',
                PVIP_NODE_STRNE() => 'ne',
                PVIP_NODE_STRNE() => 'ne',
                PVIP_NODE_STRGT() => 'gt',
                PVIP_NODE_STRGE() => 'ge',
                PVIP_NODE_STRLT() => 'lt',
                PVIP_NODE_STRLE() => 'le',
                PVIP_NODE_EQV()   => 'eq', # TODO
            }->{$type};
            unless ($op) {
                Rokugo::Exception::NotImplemented->throw(sprintf "PVIP_NODE_%s is not implemented in chaning", $type)
            }
            sprintf("(%s)%s(%s)", $lhs, $op, $rhs);
        };
        if (@$v == 1) {
            return $self->do_compile($v->[0]);
        } elsif (@$v == 2) {
            # optimized for simple case
            $compile->(
                $self->do_compile($v->[0]),
                $v->[1]->type,
                $self->do_compile($v->[1]->value->[0]),
            );
        } else {
            my $ret = 'do { my $_rg_chain_ret = 1; my $_rg_chain_rhs; my $_rg_chain_lhs = ';
            $ret .= $self->do_compile(shift @$v);
            $ret .= ';';

            while (my $rhs_node = shift @$v) {
                $ret .= sprintf('$_rg_chain_rhs=%s;', $self->do_compile($rhs_node->value->[0]));
                $ret .= sprintf('unless (%s) { $_rg_chain_ret=0; goto _RG_CHAIN_END; }', $compile->('$_rg_chain_lhs', $rhs_node->type, '$_rg_chain_rhs'));
                $ret .= '$_rg_chain_lhs=$_rg_chain_rhs;';
            }
            $ret .= '_RG_CHAIN_END: $_rg_chain_ret; }';
            return $ret;
        }
    } elsif ($type == PVIP_NODE_INPLACE_ADD) {
        '(' . $self->do_compile($v->[0]) . ')+=(' . $self->do_compile($v->[1]) . ')';
    } elsif ($type == PVIP_NODE_INPLACE_SUB) {
        '(' . $self->do_compile($v->[0]) . ')-=(' . $self->do_compile($v->[1]) . ')';
    } elsif ($type == PVIP_NODE_INPLACE_MUL) {
        '(' . $self->do_compile($v->[0]) . ')*=(' . $self->do_compile($v->[1]) . ')';
    } elsif ($type == PVIP_NODE_INPLACE_DIV) {
        '(' . $self->do_compile($v->[0]) . ')/=(' . $self->do_compile($v->[1]) . ')';
    } elsif ($type == PVIP_NODE_INPLACE_POW) {
        '(' . $self->do_compile($v->[0]) . ')**=(' . $self->do_compile($v->[1]) . ')';
    } elsif ($type == PVIP_NODE_INPLACE_MOD) {
        '(' . $self->do_compile($v->[0]) . ')%=(' . $self->do_compile($v->[1]) . ')';
    } elsif ($type == PVIP_NODE_INPLACE_BIN_OR) {
        sprintf('(%s)|=(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($type == PVIP_NODE_INPLACE_BIN_AND) {
        sprintf('(%s)&=(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($type == PVIP_NODE_INPLACE_BIN_XOR) {
        sprintf('(%s)^=(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($type == PVIP_NODE_INPLACE_BLSHIFT) {
        sprintf('(%s)<<=(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($type == PVIP_NODE_INPLACE_BRSHIFT) {
        sprintf('(%s)>>=(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
        );
    } elsif ($type == PVIP_NODE_INPLACE_CONCAT_S) {
        '(' . $self->do_compile($v->[0]) . ').=(' . $self->do_compile($v->[1]) . ')';
    } elsif ($type == PVIP_NODE_REPEAT_S) {
        '(' . $self->do_compile($v->[0]) . ')x(' . $self->do_compile($v->[1]) . ')';
    } elsif ($type == PVIP_NODE_INPLACE_REPEAT_S) {
        '(' . $self->do_compile($v->[0]) . ')x=(' . $self->do_compile($v->[1]) . ')';
    } elsif ($type == PVIP_NODE_UNARY_TILDE) {
        # stringification
        sprintf(q{''.(%s)}, $self->do_compile($v->[0]));
    } elsif ($type == PVIP_NODE_TRY) {
        "eval " . $self->do_compile($v->[0]);
    } elsif ($type == PVIP_NODE_REF) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_REF is not implemented")
    } elsif ($type == PVIP_NODE_MULTI) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_MULTI is not implemented")
    } elsif ($type == PVIP_NODE_LANG) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_LANG is not implemented")
    } elsif ($type == PVIP_NODE_UNARY_BOOLEAN) {
        sprintf 'boolean::boolean(%s)', $self->do_compile($v->[0]);
    } elsif ($type == PVIP_NODE_UNARY_UPTO) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_UNARY_UPTO is not implemented")
    } elsif ($type == PVIP_NODE_ARRAY_DEREF) {
        '@{' . $self->do_compile($v->[0]) . '}';
    } elsif ($type == PVIP_NODE_STDOUT) {
        '*STDOUT'
    } elsif ($type == PVIP_NODE_STDERR) {
        '*STDERR'
    } elsif ($type == PVIP_NODE_SCALAR_DEREF) {
        '${' . $self->do_compile($v->[0]) . '}';
    } elsif ($type == PVIP_NODE_TW_INC) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_TW_INC is not implemented")
    } elsif ($type == PVIP_NODE_META_METHOD_CALL) {
        # (meta_method_call (class (nop) (nop) (statements)) (ident "methods") (nop))
        sprintf('(%s)->meta()->%s(%s)',
            $self->do_compile($v->[0]),
            $self->do_compile($v->[1]),
            $self->do_compile($v->[2]),
        );
    } elsif ($type == PVIP_NODE_REGEXP) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_REGEXP is not implemented")
    } elsif ($type == PVIP_NODE_SMART_MATCH) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_SMART_MATCH is not implemented")
    } elsif ($type == PVIP_NODE_NOT_SMART_MATCH) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_NOT_SMART_MATCH is not implemented")
    } elsif ($type == PVIP_NODE_PERL5_REGEXP) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_PERL5_REGEXP is not implemented")
    } elsif ($type == PVIP_NODE_TRUE) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_TRUE is not implemented")
    } elsif ($type == PVIP_NODE_TW_VM) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_TW_VM is not implemented")
    } elsif ($type == PVIP_NODE_HAS) {
        # (has (public_attribute "x"))
        # support private variable
        if ($v->[0]->type == PVIP_NODE_PUBLIC_ATTRIBUTE) {
            sprintf('__PACKAGE__->meta->add_public_attribute("%s")', $v->[0]->value);
        } elsif ($v->[0]->type == PVIP_NODE_PRIVATE_ATTRIBUTE) {
            sprintf('__PACKAGE__->meta->add_private_attribute("%s")', $v->[0]->value);
        } else {
            die "Should not reach here";
        }
    } elsif ($type == PVIP_NODE_PRIVATE_ATTRIBUTE) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_PRIVATE_ATTRIBUTE is not implemented")
    } elsif ($type == PVIP_NODE_PUBLIC_ATTRIBUTE) {
        # (public_attribute "x")
        sprintf('$self->{%s}', $v);
    } elsif ($type == PVIP_NODE_FUNCREF) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_FUNCREF is not implemented")
    } elsif ($type == PVIP_NODE_PATH) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_PATH is not implemented")
    } elsif ($type == PVIP_NODE_TW_PACKAGE) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_TW_PACKAGE is not implemented")
    } elsif ($type == PVIP_NODE_TW_CLASS) {
        'Rokugo::MetaClass->new(name => __PACKAGE__)'
    } elsif ($type == PVIP_NODE_TW_MODULE) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_TW_MODULE is not implemented")
    } elsif ($type == PVIP_NODE_TW_OS) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_TW_OS is not implemented")
    } elsif ($type == PVIP_NODE_TW_PID) {
        '($$)';
    } elsif ($type == PVIP_NODE_TW_PERLVER) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_TW_PERLVER is not implemented")
    } elsif ($type == PVIP_NODE_TW_OSVER) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_TW_OSVER is not implemented")
    } elsif ($type == PVIP_NODE_TW_CWD) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_TW_CWD is not implemented")
    } elsif ($type == PVIP_NODE_TW_EXECUTABLE_NAME) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_TW_EXECUTABLE_NAME is not implemented")
    } elsif ($type == PVIP_NODE_TW_ROUTINE) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_TW_ROUTINE is not implemented")
    } elsif ($type == PVIP_NODE_SLANGS) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_SLANGS is not implemented")
    } elsif ($type == PVIP_NODE_LOGICAL_ANDTHEN) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_LOGICAL_ANDTHEN is not implemented")
    } elsif ($type == PVIP_NODE_VALUE_IDENTITY) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_VALUE_IDENTITY is not implemented")
    } elsif ($type == PVIP_NODE_CMP) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_CMP is not implemented")
    } elsif ($type == PVIP_NODE_SPECIAL_VARIABLE_REGEXP_MATCH) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_SPECIAL_VARIABLE_REGEXP_MATCH is not implemented")
    } elsif ($type == PVIP_NODE_SPECIAL_VARIABLE_EXCEPTIONS) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_SPECIAL_VARIABLE_EXCEPTIONS is not implemented")
    } elsif ($type == PVIP_NODE_ENUM) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_ENUM is not implemented")
    } elsif ($type == PVIP_NODE_NUM_CMP) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_NUM_CMP is not implemented")
    } elsif ($type == PVIP_NODE_UNARY_FLATTEN_OBJECT) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_UNARY_FLATTEN_OBJECT is not implemented")
    } elsif ($type == PVIP_NODE_COMPLEX) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_COMPLEX is not implemented")
    } elsif ($type == PVIP_NODE_ROLE) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_ROLE is not implemented")
    } elsif ($type == PVIP_NODE_IS) {
        # (is (ident "Foo7"))
        sprintf q!push @ISA, '%s'!, $self->do_compile($v->[0]);
    } elsif ($type == PVIP_NODE_DOES) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_DOES is not implemented")
    } elsif ($type == PVIP_NODE_JUNCTIVE_AND) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_JUNCTIVE_AND is not implemented")
    } elsif ($type == PVIP_NODE_JUNCTIVE_SAND) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_JUNCTIVE_SAND is not implemented")
    } elsif ($type == PVIP_NODE_JUNCTIVE_OR) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_JUNCTIVE_OR is not implemented")
    } elsif ($type == PVIP_NODE_UNICODE_CHAR) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_UNICODE_CHAR is not implemented")
    } elsif ($type == PVIP_NODE_STUB) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_STUB is not implemented")
    } elsif ($type == PVIP_NODE_EXPORTABLE) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_EXPORTABLE is not implemented")
    } elsif ($type == PVIP_NODE_PARAM) {
        # (params (param (nop) (variable "$n") (nop)))
        sprintf('my %s=shift;', $self->do_compile($v->[1]));
    } elsif ($type == PVIP_NODE_BITWISE_OR) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_BITWISE_OR is not implemented")
    } elsif ($type == PVIP_NODE_BITWISE_AND) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_BITWISE_AND is not implemented")
    } elsif ($type == PVIP_NODE_BITWISE_XOR) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_BITWISE_XOR is not implemented")
    } elsif ($type == PVIP_NODE_VARGS) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_VARGS is not implemented")
    } elsif ($type == PVIP_NODE_WHATEVER) {
        Rokugo::Exception::NotImplemented->throw("PVIP_NODE_WHATEVER is not implemented")
    } elsif ($type == PVIP_NODE_END) {
        "END " . $self->do_compile($v->[0]);
    } else {
        Rokugo::Exception::UnknownNode->throw(
             ("Unknown node: PVIP_NODE_" . uc($node->name))
        );
    }
}

sub binop {
    my ($self, $op, $v) = @_;
    sprintf('(%s)%s(%s)',
        $self->do_compile($v->[0]),
        $op,
        $v,
        $self->do_compile($v->[1]),
    );
}

sub maybe_block {
    my ($self, $node) = @_;
    if ($node->type == PVIP_NODE_BLOCK) {
        return $self->do_compile($node);
    } else {
        return '{' . $self->do_compile($node) . "}";
    }
}

1;

