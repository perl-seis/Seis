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

sub open :method {
    my $mode = @_==2 && $_[1]->key eq 'w' ? '>' : '<';
    CORE::open my $fh, $mode, $_[0];
    return $fh;
}

sub get :method {
    my $stuff = shift;
    my $line = <$stuff>;
    if (defined $line) {
        $line =~ s/\n//;
    }
    $line;
}

1;

