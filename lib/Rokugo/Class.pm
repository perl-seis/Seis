package Rokugo::Class;
use strict;
use warnings;
use utf8;
use 5.010_001;
use Rokugo::MetaClass;

# DO NOT CALL THIS METHOD DIRECTLY.
sub new {
    my $class = shift;
    my %args = @_==1 ? %{$_[0]} : @_;
    return bless { %args }, $class;
}

sub meta {
    my $self = shift;
    return Rokugo::MetaClass->new(name => $self->{name});
}

1;

