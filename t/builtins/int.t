use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;

is compile(q!97.chr!), 'a';
cmp_ok compile(q!100.rand!), '<', 100;
cmp_ok compile(q!100.rand!), '>', 0;

done_testing;

