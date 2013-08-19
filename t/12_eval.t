use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;

is compile(q!eval '"a" ~ "b"'!), 'ab';
is compile(q!eval '"a" . "b"', :lang<perl5>!), 'ab';

done_testing;

