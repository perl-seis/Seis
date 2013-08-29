package Seis::IO::Path;
use strict;
use warnings;
use utf8;
use 5.010_001;

package # Hide from PAUSE
    IO::Path;
use File::Basename ();
use File::Path ();

use overload (
    q{""} => sub {
        $_[0]->{fullpath}
    },
    fallback => 1,
);

sub new {
    my $class = shift;
    my $fullpath = shift;
    bless {
        fullpath => $fullpath
    }, $class;
}

sub basename { File::Basename::basename($_[0]->{fullpath}) }

sub perl {
    local $Data::Dumper::Terse = 1;
    local $Data::Dumper::Useqq = 1;
    local $Data::Dumper::Purity = 1;
    local $Data::Dumper::Indent = 0;
    Data::Dumper::Dumper($_[0]->{fullpath});
}
sub gist { goto &perl }
sub volume {
    my $self = shift;
    (my $volume, ) = File::Spec->splitpath($self->{fullpath});
    $volume;
}
sub directory {
    my $self = shift;
    (undef, my $volume, ) = File::Spec->splitpath($self->{fullpath});
    $volume =~ s!/\z!!r;
}
sub parent {
    require Path::Tiny;
    IO::Path->new(Path::Tiny->new($_[0])->parent->stringify);
}
{
    no strict 'refs';
    *{"isーabsolute"} = sub {
        substr( $_[0]->directory, 0, 1 ) eq '/' ? Bool::True() : Bool::False()
    };
    *{"isーrelative"} = sub {
        substr( $_[0]->directory, 0, 1 ) ne '/' ? Bool::True() : Bool::False()
    };
}

sub path { $_[0] }
sub IO {
    Seis::IO::Handle->_new($_[0]->{fullpath});
}
sub cleanup {
    File::Spec->canonpath($_[0]->{fullpath});
}


1;

