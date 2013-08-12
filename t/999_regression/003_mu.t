use t::ParserTest;
__END__

===
--- code
unless Mu { 1 }
--- expected
(statements (unless (ident "Mu") (statements (int 1))))

===
--- code
live { 3 };
--- expected
(statements (funcall (ident "live") (args (lambda (statements (int 3))))))

===
--- code
@a = map { $_ }, @a
--- expected
(statements (bind (variable "@a") (funcall (ident "map") (args (lambda (statements (variable "$_"))) (variable "@a")))))

