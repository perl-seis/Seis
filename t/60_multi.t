use t::ParserTest;
__END__
===
--- code
multi sub i() { }
--- expected
(statements (multi (func (ident "i") (params) (nop) (block))))
