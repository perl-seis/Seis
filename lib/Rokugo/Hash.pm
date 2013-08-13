package Rokugo::Hash;
use strict;
use warnings;
use utf8;
use 5.010_001;

sub keys {
    sort keys %{$_[0]}
}

1;

