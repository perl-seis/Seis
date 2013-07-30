use t::ParserTest;

__END__

===
--- code
use Perl:ver<6.*>;
--- expected
(statements (use (ident "Perl") (pair (string "ver") (string "6.*"))))

