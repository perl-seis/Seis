use t::ParserTest;
__END__

===
--- code
sub { }
--- expected
(statements (func (nop) (params) (nop) (statements)))

===
--- code
sub ok_auto { }
--- expected
(statements (func (ident "ok_auto") (params) (nop) (statements)))

===
--- code
sub is-true() { True }
--- expected
(statements (func (ident "is-true") (params) (nop) (statements (ident "True"))))

===
--- code
sub foo() is exportable { }
--- expected
(statements (func (ident "foo") (params) (exportable) (statements)))

===
--- code
sub foo($n) { }
--- expected
(statements (func (ident "foo") (params (param (nop) (variable "$n") (nop))) (nop) (statements)))

===
--- code
sub foo(Int $n) { }
--- expected
(statements (func (ident "foo") (params (param (ident "Int") (variable "$n") (nop))) (nop) (statements)))

===
--- code
sub foo(Str $n="Ah") { }
--- expected
(statements (func (ident "foo") (params (param (ident "Str") (variable "$n") (string "Ah"))) (nop) (statements)))

===
--- code
(-> $n { say($n) })(5)
--- expected
(statements (funcall (lambda (params (param (nop) (variable "$n") (nop))) (statements (funcall (ident "say") (args (variable "$n"))))) (args (int 5))))
