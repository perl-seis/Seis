use t::ParserTest;

__END__

===
--- code
sub foo(*@a) { }
--- expected
(statements (func (ident "foo") (params (param (vargs (variable "@a")))) (nop) (statements)))

===
--- code
method foo(*@a) { }
--- expected
(statements (method (ident "foo") (params (param (vargs (variable "@a")))) (statements)))
