package Rokugo::Int;
use strict;
use warnings;
use utf8;
use 5.010_001;
use boolean ();

sub perl { $_[0] }

sub clone { 0+$_[0] }

sub say { CORE::say($_[0]) }

sub isa {
    my ($self, $stuff) = @_;
    use Devel::Peek; Dump($self);
    # Yes, it's boolean.
    return 1 if boolean::isBoolean($self) && $stuff eq 'Rokugo::Bool';
    return 1 if $stuff eq 'Int';
    return 0;
}

sub Bool { boolean::boolean($_[0]) }

sub WHAT {
    my $self = shift;
    Rokugo::Class->new(name => 'Int');
}

use Math::BaseCnv;
sub base {
    my ($num, $base) = @_;
    Math::BaseCnv::cnv($num, 10, $base);
}

sub defined { 1 }

sub chr: method { CORE::chr($_[0]) }

sub rand:method { CORE::rand($_[0]) }

{
    # Note.
    # I don't think Math::Prime::Util is the best solution to solve the 'is_prime' problem.
    # If you know the best module for this issue, patches welcome.
    # Small memory foot point is great. And if you can write a fast xs code, it's the best.
    sub isーprime {
        require Math::Prime::Util;
        Math::Prime::Util::is_prime($_[0])
    };
}

1;

