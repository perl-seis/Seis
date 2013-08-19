requires 'perl', '5.018000';

requires 'Exception::Tiny';
requires 'Perl6::PVIP', 0.04;
requires 'autobox', 2.79;
requires 'Caroline';
requires 'Class::XSAccessor', 1.16;
requires 'boolean';
requires 'Math::BaseCnv';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

