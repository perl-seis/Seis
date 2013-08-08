use t::ParserTest;

__END__

===
--- code
class { }
--- expected
(statements (class (nop) (nop) (statements)))

===
--- code
class Foo { }
--- expected
(statements (class (ident "Foo") (nop) (statements)))

===
--- code
class NotComplex is Cool { }
--- expected
(statements (class (ident "NotComplex") (list (is (ident "Cool"))) (statements)))

===
--- code
3.WHAT.gist
--- expected
(statements (methodcall (methodcall (int 3) (ident "WHAT")) (ident "gist")))

===
--- code
multi method foo() { }
--- expected
(statements (multi (method (ident "foo") (nop) (statements))))

===
--- code
@foo.push: 3
--- expected
(statements (methodcall (variable "@foo") (ident "push") (args (int 3))))

===
--- code
$foo.^methods
--- expected
(statements (meta_method_call (variable "$foo") (ident "methods") (nop)))

===
--- code
$foo.^methods(3)
--- expected
(statements (meta_method_call (variable "$foo") (ident "methods") (args (int 3))))

===
--- code
class A { has $.b }
--- expected
(statements (class (ident "A") (nop) (statements (has (private_attribute "b")))))

===
--- code
class A { has $!b }
--- expected
(statements (class (ident "A") (nop) (statements (has (public_attribute "b")))))

===
--- code
class Foo::Bar { }
--- expected
(statements (class (ident "Foo::Bar") (nop) (statements)))

===
--- code
role C { }
--- expected
(statements (role (statements)))

=== class A is B is C
--- code
class A is B is C { }
--- expected
(statements (class (ident "A") (list (is (ident "B")) (is (ident "C"))) (statements)))

