package Rokugo::Autobox;
use strict;
use warnings;
use utf8;
use 5.010_001;
use parent qw(autobox);

sub import {
    my $class = shift;
    $class->SUPER::import(
        ARRAY   => 'Array',
        INTEGER => 'Rokugo::Int',
        FLOAT   => 'Rokugo::Real',
        STRING  => 'Str',
        CODE    => 'Sub',
        HASH    => 'Rokugo::Hash',
        UNDEF   => 'Rokugo::Undef',
    );
}

1;
