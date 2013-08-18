package Rokugo::BuiltinFunctions;
use strict;
use warnings;
use utf8;
use 5.010_001;

sub end { @{$_[0]}-1 }
sub end_list { @_-1 }

1;

