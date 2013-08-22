package Rokugo::Object;
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

sub meta {
    my $self = shift;
    my $pkg = ref $self || $self;
    no strict 'refs';
    my $meta = Rokugo::MetaClass->new(name => $pkg);
    *{"${pkg}::_meta"} = sub { $meta };
    $meta;
}

sub WHAT {
    my $self = shift;
    Rokugo::Class->new(name => Scalar::Util::blessed($self));
}

1;

