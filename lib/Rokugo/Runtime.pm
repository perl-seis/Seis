package Rokugo::Runtime;
use strict;
use warnings;
use utf8;
use 5.010_001;

use Rokugo::Object;
use Rokugo::Array;
use Rokugo::Int;
use Rokugo::Real;
use Rokugo::Exceptions;
use Rokugo::Str;
use Rokugo::Hash;
use Rokugo::MetaClass;
use Rokugo::Class;
use Rokugo::Range;
use Rokugo::Undef;
use Rokugo::Buf;
use Rokugo::Whatever;
use Rokugo::Pair;

use Rokugo::BuiltinFunctions;

{
    package # hide from PAUSE
        Complex;
    sub new {
        my ($class, $x, $y) = @_;
        bless {x => $x, y => $y}, $class;
    }
}

sub builtin_eval {
    my ($code) = @_;
    my $compiler = Rokugo::Compiler->new();
    my $compiled = $compiler->compile($code);
    my $ret = eval $compiled;
    if ($@) {
        Rokugo::Exception::CompilationFailed->new("$@");
    }
    return $ret;
}

sub builtin_elems { 0+@_ }

{
    package Rokugo::Match;
    sub DESTROY { }
    sub TIEARRAY {
        my $class = shift;
        bless {}, $class;
    }
    sub FETCHSIZE {
        1 + @-;
    }
    sub FETCH($$) {
        my ($self, $index) = @_;
        return ${^MATCH} if $index == 0;
        return $-[$index-1];
    }
}

# This variable emulates $/ in Perl6.
our @REGEXP_MATCH;
tie @REGEXP_MATCH, 'Rokugo::Match';

1;

