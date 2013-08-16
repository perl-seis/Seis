package Rokugo::Array;
use strict;
use warnings;
use utf8;
use 5.010_001;

sub pop:method { CORE::pop $_[0] }
sub push:method { CORE::push $_[0], $_[1] }
sub elems:method { 0+@{$_[0]} }

# is(([+] (1..999).grep( { $_ % 3 == 0 || $_ % 5 == 0 } )), 233168, 'Project Euler #1');
sub grep {
    my ($self, $code) = @_;
    grep { $code->() } @$self;
}

sub join {
    my ($self, $stuff) = @_;

    join $stuff, @$self;
}

sub WHAT {
    Rokugo::Class->new(name => 'Array');
}

1;

