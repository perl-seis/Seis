package Rokugo::Hash;
use strict;
use warnings;
use utf8;
use 5.010_001;
use Rokugo::Pair;

sub keys:method {
    sort keys %{$_[0]}
}

sub WHAT {
    my $self = shift;
    Rokugo::Class->new(name => 'Hash');
}

sub pairs:method {
    my $self = shift;
    my @ret;
    while (my ($k, $v) = each %$self) {
        push @ret, bless [$k, $v], Rokugo::Pair::;
    }
    return wantarray ? @ret : \@ret;
}

1;

