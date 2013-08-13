package Rokugo::Array;
use strict;
use warnings;
use utf8;
use 5.010_001;

sub pop:method { CORE::pop $_[0] }
sub push:method { CORE::push $_[0], $_[1] }
sub elems:method { 0+@{$_[0]} }


1;

