package Rokugo::Any;
use strict;
use warnings;
use utf8;
use 5.010_001;


sub _new {
    my $class = shift;
    bless [@_], $class;
}

1;

