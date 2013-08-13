package Hybrid::Object;
use strict;
use warnings;
use utf8;
use 5.010_001;

# TODO: make more perl6-ish.
sub new {
    my $class = shift;
    my %args = @_==1 ? %{$_[0]} : @_;
    bless { %args }, $class;
}

1;

