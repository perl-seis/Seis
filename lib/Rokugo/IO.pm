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

sub print:method {
    my $self = shift;
    print {$self->{fh}} shift;
}

sub close:method {
    my $self = shift;
    close $self->{fh};
}

sub getc:method {
    my $self = shift;
    getc $self->{fh};
}

1;

