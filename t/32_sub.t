use t::ParserTest;
__END__

===
--- code
sub ($n) { }
--- expected
(statements (func (nop) (params (param (nop) (variable "$n") (nop))) (nop) (block)))
