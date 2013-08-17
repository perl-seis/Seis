use t::ParserTest;
__END__
=== 
--- code
1 gcd 2
--- expected
(statements (gcd (int 1) (int 2)))

===
--- code
[gcd] 1, 2
--- expected
(statements (reduce (string "gcd") (list (int 1) (int 2))))
