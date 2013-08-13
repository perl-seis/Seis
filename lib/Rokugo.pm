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
        my $compiled = $compiler->compile($code) . ";1;";
        open my $tmpfh, '<', \$compiled;
        return ($tmpfh, sub {
            $_ =~ s/hello/hi/;
            $_ ? 1 : 0;
        });
    }
    return;
};


1;
__END__

=encoding utf-8

=head1 NAME

Rokugo - It's new $module

=head1 SYNOPSIS

    use Rokugo;

=head1 DESCRIPTION

Rokugo is ...

=head1 TODO

Renamed to Rokugo

=head1 LICENSE

Copyright (C) tokuhirom.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

tokuhirom E<lt>tokuhirom@gmail.comE<gt>

=cut

