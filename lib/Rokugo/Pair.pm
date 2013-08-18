package Rokugo::Pair;
use strict;
use warnings;
use utf8;
use 5.010_001;

# Do not call this directly.
sub _new {
    my ($class, $key, $value) = @_;
    bless [$key, $value], $class;
}

sub key { $_->[0] }
sub value { $_->[0] }

1;

