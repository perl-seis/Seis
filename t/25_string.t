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
(statements (string_concat (string "aa") (statements (add (int 3) (int 2)))))

===
--- code
"\{"
--- expected
(statements (string "{"))

===
--- code
"{}"
--- expected
(statements (string ""))

===
--- code
"{ }"
--- expected
(statements (string ""))

===
--- code
"{use v5;}"
--- expected
(statements (string_concat (string "") (statements (use (ident "v5")))))

===
--- code
"\c[LINE FEED (LF)]"
--- expected
(statements (string_concat (string "") (unicode_char "LINE FEED (LF)")))

===
--- code
'\c[LINE FEED (LF)]'
--- expected
(statements (string "\\c[LINE FEED (LF)]"))

===
--- code
"\c10"
--- expected
(statements (string "\n"))
