my $cnt = 0;
my $failed = 0;

sub plan($n) is export {
    say("1..$n");
}

sub proclaim($cond, $desc) {
    unless $cond {
        print "not ";
        $failed++;
    }
    $cnt++;
    print "ok $cnt\n";
    return $cond;
}

sub ok($cond, $desc) is export {
    proclaim($cond, $desc);
}

sub nok($cond, $desc=undef) is export {
    proclaim(!$cond, $desc);
}

sub is($x,$y) is export {
    proclaim($x eq $y);
}

sub isa_ok($x, $y, $desc=undef) is export {
    proclaim($x.isa($y), $desc);
}

sub lives_ok($closure, $reason='') is export {
    try {
        $closure();
    };
    proclaim((not defined $!), $reason);
}

sub dies_ok($closure, $reason='') is export {
    try {
        $closure();
    };
    proclaim((defined $!), $reason);
}

sub eval_dies_ok($code, $reason=undef) is export {
    my $ee = eval_exception($code);
    if defined $ee {
        proclaim(1, $reason);
    } else {
        proclaim(0, $reason);
    }
}

sub eval_lives_ok($code, $reason=undef) is export {
    my $ee = eval_exception($code);
    if defined $ee {
        proclaim(0, $reason);
    } else {
        proclaim(1, $reason);
    }
}

sub eval_exception($code) {
    try {
        eval $code;
    };
    $!;
}

END {
    exit 1 if $failed > 0;
}
