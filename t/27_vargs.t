use t::ParserTest;

__END__

===
--- code
sub foo(*@a) { }
--- expected
(statements (func (ident "foo") (params (param (vargs (variable "@a")))) (nop) (block)))

===
--- code
method foo(*@a) { }
--- expected
(statements (method (ident "foo") (params (param (vargs (variable "@a")))) (block)))
