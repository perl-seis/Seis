use t::ParserTest;
__END__

===
--- code
class Foo        { has $.foo_build; submethod BUILD() { $!foo_build++ } }
--- expected
(statements (class (ident "Foo") (nop) (block (statements (has (private_attribute "foo")) (int 0) (ident "build") (submethod (ident "BUILD") (nop) (block (statements (public_attribute "foo") (int 0) (postinc (ident "build")))))))))
