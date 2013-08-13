use strict;
use warnings;
use utf8;
use Test::More;
use Rokugo::Compiler;

is(compile('1.perl'), 1);
is(compile('(3.14).perl'), 3.14);
is(compile('"Heh\nhoh".perl'), '"Heh\nhoh"');

sub compile {
    my $code = shift;

    my $compiler = Rokugo::Compiler->new();
    my $compiled = $compiler->compile($code);
    note 'code: ' . $code;
    note 'compiled: ' .  $compiled;
    note 'sexp: ' . eval { Perl6::PVIP->new->parse_string($code)->as_sexp } || 'err';

    my $result = eval $compiled;
    ok !$@ or diag $@;
    return $result;
}

done_testing;

