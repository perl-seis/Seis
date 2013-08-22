package Rokugo::List;
use strict;
use warnings;
use utf8;
use 5.010_001;

package # Hide from PAUSE
    List;

sub new {
    my ($class, @ary) = @_;
    bless \@ary, $class;
}

1;

