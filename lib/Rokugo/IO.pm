package Rokugo::IO;
use strict;
use warnings;
use utf8;
use 5.018_000;

sub _new {
    my ($class, $path) = @_;
    bless { path => $path }, $class;
}

# return Rokugo::IO->_new_with_fh($_[0], $fh);
sub _new_with_fh {
    my ($class, $path, $fh) = @_;
    bless { path => $path, fh => $fh }, $class;
}

sub lines {
    my $self = shift;
    my $fh = $self->{fh};
    my @lines = <$fh>;
    @lines;
}

sub eof:method {
    CORE::eof($_[0]->{fh});
}

sub get:method {
    my $self = shift;
    my $fh = $self->{fh};
    <$fh>;
}

1;

