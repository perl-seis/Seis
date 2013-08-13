package t::Util;
use strict;
use warnings;
use utf8;
use 5.010_001;
use parent qw(Exporter);
use Rokugo::Compiler;
use Test::More;

our @EXPORT = qw(compile);

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

1;
