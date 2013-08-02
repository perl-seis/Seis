use t::ParserTest;
__END__

===
--- code
"aa\c[GREEK CAPITAL LETTER ALPHA]"
--- expected
(statements (string_concat (string "aa") (unicode_char "GREEK CAPITAL LETTER ALPHA")))

===
--- code
"aa{3+2}"
--- expected
(statements (string_concat (string "aa") (add (int 3) (int 2))))
