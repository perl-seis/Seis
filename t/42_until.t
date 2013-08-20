use t::ParserTest;

__END__

===
--- code
until 1 { 2 }
--- expected
(statements (until (int 1) (block (statements (int 2)))))

