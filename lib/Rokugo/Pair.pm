package Rokugo::Pair;
use strict;
use warnings;
use utf8;
use 5.010_001;
use overload (
    '~~' => '_match',
    fallback => 1,
);

# Do not call this directly.
sub _new {
    my ($class, $key, $value) = @_;
    bless [$key, $value], $class;
}

sub key   { $_[0]->[0] }
sub value { $_[0]->[1] }

sub _match {
    my ($self, $stuff) = @_;
    if (UNIVERSAL::isa($stuff, 'Rokugo::IO')) {
        my $ret = eval "-$self->[0] " . Rokugo::Str::perl($stuff->{path});
        die $@ if $@;
        $ret;
    } else {
        ...
    }
}

1;

