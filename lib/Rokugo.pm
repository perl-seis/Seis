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
    (my $rg_fname = $fname) =~ s!\.pm\z!\.rg!
        or return;
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

=for stopwords transpiler rokugo

=encoding utf-8

=head1 NAME

Rokugo - Perl6 on Perl5

=head1 SYNOPSIS

    for 1..100 { .say }

=head1 DESCRIPTION

Rokugo is transpiler for Perl6's syntax to Perl5.

It's only emulate perl6's syntax. Not semantics.

But it's useful because perl6's syntax is sane.

=head1 PROJECT PLANS

=head2 Version 1.0 - Maybe production ready release

=over 4

=item Support basic Perl6 OOP features

=item Support basic Perl6 regexp

=back

=head1 TODO

    Implement builtin methods
    multi methods
    perl6 regexp
    perl6 rules
    perl6 junctions
    perl6 open
    perl6 slurp
    pass the 200+ roast cases
    care the pairs
    my own virtual machine?

=head2 Issues in PVIP

c<<end (1,2,3)>> and C<<end(1,2,3)>> is a different thing.
But PVIP handles these things are same.

=head1 WHY ROKUGO REQUIRES Perl 5.10+?

=over 4

=item //p flag

//p flag was introduced at 5.10. It's needed by regexp operation.

=back

=head1 WHY ROKUGO REQUIRES Perl 5.16?

=over 4

=item fc()

Perl6 provides C< String#fc > method. Perl5 supports fc()  5.16 or later.

=back

=head1 KNOWN ISSUES

There is some known issues. Rokugo do in the forcible way.
And Rokugo placed great importance on performance.
Then, rokugo giving ups some features on Perl 6.

If you have any ideas to support these things without performance issue, patches welcome(I guess most of features can fix if you are XS hacker).

=head1 Compiling regeular expression is slow.

It can be optimizable.

=head1 1..* was not supported.

You can implement this by dankogai's hack.

http://blog.livedoor.jp/dankogai/archives/50839189.html

=head2 Compilation speed is optimizable

You can rewrite code generator to generate B tree directly.

I know it's the best way, but I don't have enough knowledge to do.
Please help us.

=head2 Automatic literal conversion is not available

Perl6 has some more string literals perl5 does not have.

For example, I can't generate fast code from following code:

    say 'ok ', '0b1010' + 1;
    say 'ok ', '0o6' * '0b10';

Note. There is a idea... You can support this feature in fast code with XS magic. You can replace PP code in XS world...

Another option, you can send a patch for support perl6 style literals to p5p.

=head2 No stringification available about refs

Following code does not works well. I need overloading stuff in autobox.pm.

    ~<a b>

This issue can solve with PP_check hack.

=head2 C<eqv> operator is not compatible.

Not yet implemented.

=head1 LICENSE

Copyright (C) tokuhirom.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

tokuhirom E<lt>tokuhirom@gmail.comE<gt>

=cut

