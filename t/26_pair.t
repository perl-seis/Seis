use t::ParserTest;

__END__

===
--- code
:$x
--- expected
(statements (pair (string "$x") (variable "$x")))

===
--- code
:todo(1)
--- expected
(statements (pair (string "todo") (int 1)))
