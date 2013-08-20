package Rokugo::Exception;
use strict;
use warnings;
use utf8;
use 5.010_001;
use parent qw(Exception::Tiny);

sub WHAT {
    my $self = shift;
    Rokugo::Class->new(name => 'Exception');
}

1;

