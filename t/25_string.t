use t::ParserTest;
__END__

===
--- code
"aa\c[GREEK CAPITAL LETTER ALPHA]"
--- expected
(statements (string_concat (string "aa") (unicode_char "GREEK CAPITAL LETTER ALPHA")))
