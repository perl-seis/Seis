requires 'perl', '5.010001';
requires 'Exception::Tiny';
requires 'Perl6::PVIP', 0.01;
requires 'autobox', 2.79;
requires 'Caroline';
requires 'Class::XSAccessor', 1.16;

on 'test' => sub {
    requires 'Test::More', '0.98';
};

