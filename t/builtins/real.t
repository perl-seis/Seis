use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;

is compile('(3.14).Int'), 3;

done_testing;

