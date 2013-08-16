use t::ParserTest;
__END__
===
--- code
END { 3 } 
--- expected
(statements (end (block (statements (int 3)))))
