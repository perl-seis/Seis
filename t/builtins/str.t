use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;

is(compile('"Hoge".fc'), 'hoge');

done_testing;

