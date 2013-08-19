#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use 5.010000;
use autodie;
use File::Spec::Functions;
use File::Basename;
use File::Path;

my $roast_base = glob("~/dev/roast/");
while (<>) {
    if (m!/dev/roast/(\S+) \.*\.\. ok!) {
        my $name = $1;
        next if $name eq 'S02-lexical-conventions/bom.t';

        my $srcpath = catfile($roast_base, $name);
        my $src = slurp($srcpath);
        my $dstpath =  "t/roast/$name";
        mkpath dirname($dstpath);
        open my $fh, '>', $dstpath;
        print $fh "#! ./blib/script/rg\n";
        print $fh $src;
    }
}

sub slurp {
    my $fname = shift;
    open my $fh, '<', $fname
        or Carp::croak("Can't open '$fname' for reading: '$!'");
    scalar(do { local $/; <$fh> })
}
