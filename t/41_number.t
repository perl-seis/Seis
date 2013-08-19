use t::ParserTest;
__END__

===
--- code
3.14e1
--- expected
(statements (number 31.4))

===
--- code
3.14e0
--- expected
(statements (number 3.14))
