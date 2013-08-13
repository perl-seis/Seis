package Hybrid::Int;
use strict;
use warnings;
use utf8;
use 5.010_001;

sub perl { $_[0] }

sub clone { 0+$_[0] }

sub say { CORE::say($_[0]) }

1;

