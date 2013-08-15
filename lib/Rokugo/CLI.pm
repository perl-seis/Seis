package Rokugo::CLI;
use strict;
use warnings;
use utf8;
use 5.010_001;

use Caroline;
use Rokugo;
use Getopt::Long;
use Data::Dumper;
use Perl6::PVIP;

use Class::XSAccessor
    accessors => {
        map { $_ => $_ } qw(
            dump_ast
            dump_compiled
        )
    }
;

sub new {
    my $class = shift;
    bless {}, $class;
}

sub run {
    my $self = shift;

    my $p = Getopt::Long::Parser->new(
        config => [qw(posix_default no_ignore_case auto_help)]
    );
    $p->getoptions(
        'e=s'       => \my $eval,
        'debug'     => \$self->{dump_compiled},
        'ast'       => \$self->{dump_ast},
    );

    if (defined $eval) {
        $self->compile_and_run($eval, '-e');
    } elsif (@ARGV) {
        my $fname= shift @ARGV;
        open my $fh, '<', $fname
            or Carp::croak("Can't open '$fname' for reading: '$!'");
        my $src = scalar(do { local $/; <$fh> });
        $self->compile_and_run($src, $fname);
    } else {
        $self->run_repl();
    }
}

sub run_repl {
    my $self = shift;

    my $caroline = Caroline->new();
    while (defined(my $line = $caroline->readline('rokugo> '))) {
        if ($line =~ /\S/) {
            $caroline->history_add($line);
            my $compiled = $self->compile($line, '<repl>');
            my $ret = eval $compiled;
            if ($@) {
                print STDERR $@ . "\n";
            } else {
                warn Dumper($ret);
            }
        }
    }
}

sub compile_and_run {
    my ($self, $code, $filename) = @_;
    my $compiled = $self->compile($code, $filename);
    my $ret = eval $compiled;
    die $@ if $@;
    $ret;
}

sub compile {
    my ($self, $code, $filename) = @_;

    my $compiler = Rokugo::Compiler->new();
    my $compiled = $compiler->compile($code, $filename);
    if ($self->dump_ast) {
        print "*** AST ***\n";
        print Perl6::PVIP->new->parse_string($code)->as_sexp;
        print "\n*** /AST ***\n";
        print "\n\n";
    }
    if ($self->dump_compiled) {
        print "------ Compiled code:\n$compiled\n---------------\n";
    }
    return $compiled;
}

1;

