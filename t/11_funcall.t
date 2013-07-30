use t::ParserTest;
__END__

===
--- code
is(1,2,);
--- expected
(statements (funcall (ident "is") (args (int 1) (int 2))))

===
--- code
is-true()
--- expected
(statements (funcall (ident "is-true") (args)))
