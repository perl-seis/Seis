package Rokugo::Class;
use strict;
use warnings;
use utf8;
use 5.010_001;
use Rokugo::MetaClass;

our %INSTANCES;

# DO NOT CALL THIS METHOD DIRECTLY.
sub new {
    my $class = shift;
    my %args = @_==1 ? %{$_[0]} : @_;
    if ($args{name}) {
        $INSTANCES{$args{name}} //= bless { %args }, $class;
    } else {
        bless { %args }, $class;
    }
}

sub meta {
    my $self = shift;
    return Rokugo::MetaClass->new(name => $self->{name});
}

sub gist {
    my $self = shift;
    '(' . $self->{name} . ')';
}

1;

