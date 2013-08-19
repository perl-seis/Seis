package Rokugo::IO::Path;
use strict;
use warnings;
use utf8;
use 5.010_001;
use File::Basename ();

sub new {
    my $class = shift;
    my $fullpath = shift;
    bless {
        fullpath => $fullpath
    }, $class;
}

sub basename { File::Basename::basename($_[0]->{fullpath}) }

1;

