use t::ParserTest;

__END__

===
--- code
while 1 { }
--- expected
(statements (while (int 1) (statements)))

===
--- code
for 1 { }
--- expected
(statements (for (int 1) (statements)))

===
--- code
while @a.pop -> $n { }
--- expected
(statements (while (methodcall (variable "@a") (ident "pop")) (lambda (params (param (nop) (variable "$n") (nop))) (statements))))

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

