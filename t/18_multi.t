#! ./blib/script/seis
use v6;

use Test;

multi sub identify(Int $x) { return "Int:$x"; }

multi sub identify(Str $x) {
    return "Str:$x";
}

multi sub identify(Int $x, Str $y) {
    return "Int:$x,Str:$y";
}

multi sub identify(Str $x, Int $y) {
    return "Str:$x,Int:$y";
}

multi sub identify(Int $x, Int $y) {
    return "Int:$x,Int:$y";
}

multi sub identify(Str $x, Str $y) {
    return "Str:$x,Str:$y";
}

is(identify(42), 'Int:42');
is(identify("Foo"), 'Str:Foo');
is(identify(42, "Foo"), 'Int:42,Str:Foo');
is(identify("Foo", 42), 'Str:Foo,Int:42');
is(identify("Foo", "Bar"), 'Str:Foo,Str:Bar');
is(identify(42, 24), 'Int:42,Int:24');

done;
