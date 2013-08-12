use t::ParserTest;
__END__
===
--- code
unless Mu { 1 }
--- expected
(statements (unless (ident "Mu") (statements (int 1))))
