#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use 5.010000;
use autodie;
use File::Find::Rule;
use Time::Piece;
use Time::HiRes qw(gettimeofday tv_interval);
use LWP::UserAgent;
use HTTP::Date;
use TAP::Harness;
use File::Spec;
use File::pushd;

system("./Build");
system('cd ~/dev/roast/ && git reset HEAD --hard && git pull origin master');
my @tests = sort File::Find::Rule->file()
                              ->name( '*.t' )
                              ->in( glob('~/dev/roast/') );

local $ENV{PERL5LIB} = File::Spec->rel2abs('lib/');
local $ENV{PERL_ROKUGO_LIB} = File::Spec->rel2abs('share/rglib/') . ':' . glob("~/dev/roast/packages/");
my $t0 = [gettimeofday];
my $rgbin = File::Spec->rel2abs('./blib/script/rg');

my $aggregate = do {
    my $pushd = pushd(glob("~/dev/roast"));
    my $harness = TAP::Harness->new({
        exec => [$rgbin],
    });
    $harness->runtests(@tests);
};
my $passed = $aggregate->passed;
my $failed = $aggregate->failed + $aggregate->parse_errors;

my $elapsed = tv_interval($t0);
my $percentage = 100.0*((1.0*$passed)/(1.0*($passed+$failed)));
printf "%s - OK: %s, FAIL: %s ( %.2f%%) in %s sec\n", localtime->strftime('%Y-%m-%d %H:%M'), $passed, $failed, $percentage, $elapsed;

my $datetime = time2str(time);

my $hf_base = "http://hf.64p.org/api/perl6/rokugo";

my $ua = LWP::UserAgent->new();
my $res = $ua->post("$hf_base/passed", [number => $passed, datetime => $datetime]);
warn $res->as_string unless $res->is_success;
$ua->post("$hf_base/failed", [number => $failed, datetime => $datetime]);
# $ua->post("$hf_base/percentage", [number => $percentage, datetime => $datetime]);
$ua->post("$hf_base/elapsed", [number => int($elapsed*1000), datetime => $datetime]);
$ua->post("$hf_base/total", [number => $passed+$failed, datetime => $datetime]);
