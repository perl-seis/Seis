package Rokugo;
use strict;
use warnings;

use 5.010001;

our $VERSION = "0.01";

use Rokugo::Exceptions;
use Rokugo::Compiler;
use Rokugo::Array;
use File::Spec;

my $compiler = Rokugo::Compiler->new();

unshift @INC, sub {
    my ($self, $fname) = @_;
    (my $rg_fname = $fname) =~ s!\.pm\z!\.rg!;
    for my $inc (@INC) {
        next if ref $inc;
        my $real = File::Spec->catfile($inc, $rg_fname);
        next unless -f $real;

        open my $fh, '<', $real or die $!;
        my $code = do { local $/; <$fh> };
        my $compiled = $compiler->compile($code, $real) . ";1;";
        open my $tmpfh, '<', \$compiled;
        return $tmpfh;
    }
    return;
};


1;
__END__

=encoding utf-8

=head1 NAME

Rokugo - Perl6 on Perl5

=head1 SYNOPSIS

    for 1..100 { .say }

=head1 DESCRIPTION

Rokugo is transpiler for Perl6's syntax to Perl5.

It's only emulate perl6's syntax. Not semantics.

But it's useful because perl6's syntax is sane.

=head1 TODO

    Support 'has' and attributes.
    Implement builtin methods

=head1 LICENSE

Copyright (C) tokuhirom.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

tokuhirom E<lt>tokuhirom@gmail.comE<gt>

=cut

