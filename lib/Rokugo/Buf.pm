package Rokugo::Buf;
use strict;
use warnings;
use utf8;
use 5.010_001;

sub new {
    my ($class, @args) = @_;
    bless [@args], $class;
}

1;

