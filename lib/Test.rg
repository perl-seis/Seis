my $cnt = 0;

sub plan($n) is exportable {
    say("1..$n");
}

sub ok($x) is exportable {
    unless $x {
        print "not ";
    }
    $cnt++;
    print "ok $cnt\n";
}

