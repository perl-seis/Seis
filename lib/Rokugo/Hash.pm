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
        push @ret, bless [$k, $v], Pair::;
    }
    return wantarray ? @ret : \@ret;
}

sub fmt {
    my ($self, $pattern, $joiner) = @_;
    $pattern //= "%s\t%s";
    join($joiner, map { sprintf($pattern, $_, $self->{$_}) } keys %$self);
}

sub kv {
    my $self = shift;
    map { $_ => $self->{$_} } keys %$self;
}

1;

