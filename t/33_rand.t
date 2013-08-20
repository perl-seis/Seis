use t::ParserTest;
__END__

===
--- code
( rand * Inf )
--- expected
(statements (mul (rand) (ident "Inf")))

===
--- code
( now * Inf )
--- expected
(statements (mul (now) (ident "Inf")))
