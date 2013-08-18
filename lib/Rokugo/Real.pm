package Rokugo::Real;
use strict;
use warnings;
use utf8;
use 5.010_001;

sub perl { $_[0] }

sub say { CORE::say($_[0]) }

sub clone { 0+$_[0] }

sub WHAT {
    my $self = shift;
    Rokugo::Class->new(name => 'Rat');
}

sub Int { CORE::int($_[0]) }

1;

