use t::ParserTest;
__END__

===
--- code
( rand * Inf )
--- expected
(statements (mul (rand) (ident "Inf")))
