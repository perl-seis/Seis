use t::ParserTest;
__END__

===
--- code
$e<ook!>
--- expected
(statements (atkey (variable "$e") (string "ook!")))

===
--- code
$e<ook?>
--- expected
(statements (atkey (variable "$e") (string "ook?")))

===
--- code
$e<ook.>
--- expected
(statements (atkey (variable "$e") (string "ook.")))
