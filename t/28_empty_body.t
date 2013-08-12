use t::ParserTest;

__END__

===
--- code
while 1 { }
--- expected
(statements (while (int 1) (nop)))

===
--- code
if 1 { }
--- expected
(statements (if (int 1) (nop)))

===
--- code
unless 1 { }
--- expected
(statements (unless (int 1) (nop)))

