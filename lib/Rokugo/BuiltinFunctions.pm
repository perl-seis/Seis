package Rokugo::BuiltinFunctions;
use strict;
use warnings;
use utf8;
use 5.010_001;

sub end { @{$_[0]}-1 }
sub end_list { @_-1 }

sub slurp {
    if (@_==1) {
        my $fname = shift;
        open my $fh, '<', $fname
            or Carp::croak("Can't open '$fname' for reading: '$!'");
        scalar(do { local $/; <$fh> })
    } else {
        ...
    }
}

1;

