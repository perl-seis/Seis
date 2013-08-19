package Rokugo::IO;
use strict;
use warnings;
use utf8;
use 5.018_000;

sub _new {
    my ($class, $path) = @_;
    bless { path => $path }, $class;
}

1;

