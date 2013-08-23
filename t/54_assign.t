use t::ParserTest;
__END__

===
--- code
($x, $y) = (1,2)
--- expected
(statements (list_assignment (list (variable "$x") (variable "$y")) (list (int 1) (int 2))))

===
--- code
($x, $y, $z) = (1,2,3)
--- expected
(statements (list_assignment (list (variable "$x") (variable "$y") (variable "$z")) (list (int 1) (int 2) (int 3))))

