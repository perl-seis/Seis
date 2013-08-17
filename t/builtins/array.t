use strict;
use warnings;
use utf8;
use Test::More;
use t::Util;

is compile('my $a = <a b c>; $a[0]'), 'a';
is compile('my @a = <a b c>; @a[0]'), 'a';
is compile('my @a; @a = <a b c>; @a[0]'), 'a';
is compile('my $a; $a = <a b c>; $a[0]'), 'a';
is compile(q!['a', <2 three>].elems!), 3;
is compile(q!my $c = [[1], [2], [3]].map( { $_ } );$c.elems!), 3;

done_testing;

