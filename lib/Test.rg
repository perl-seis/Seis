my $cnt = 0;
my $failed = 0;

sub plan($n) is exportable {
    say("1..$n");
}

sub ok($x) is exportable {
    unless $x {
        print "not ";
        $failed++;
    }
    $cnt++;
    print "ok $cnt\n";
}

sub nok($x, $desc=undef) is exportable {
    ok(!$x, $desc);
}

sub is($x,$y) is exportable {
    ok($x eq $y);
}

sub isa_ok($x, $y, $desc=undef) is exportable {
    ok($x.isa($y), $desc);
}

END {
    exit 1 if $failed > 0;
}
