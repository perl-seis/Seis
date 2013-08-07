use t::ParserTest;

__END__

===
--- code
:$x
--- expected
(statements (pair (string "$x") (variable "$x")))
