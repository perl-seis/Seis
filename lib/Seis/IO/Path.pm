package Seis::IO::Path;
use strict;
use warnings;
use utf8;
use 5.010_001;

package # Hide from PAUSE
    IO::Path;
use File::Basename ();

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

1;

