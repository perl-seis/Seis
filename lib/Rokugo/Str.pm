package Rokugo::Str;
use strict;
use warnings;
use utf8;
use 5.010_001;
use Data::Dumper ();

sub uc:method { CORE::uc($_[0]) }
sub lc:method { CORE::lc($_[0]) }

sub say { CORE::say($_[0]) }

sub perl {
    local $Data::Dumper::Terse = 1;
    local $Data::Dumper::Useqq = 1;
    local $Data::Dumper::Purity = 1;
    local $Data::Dumper::Indent = 0;
    Data::Dumper::Dumper($_[0]);
}

sub clone { "$_[0]" }

sub Bool { boolean::boolean($_[0]) }

1;

