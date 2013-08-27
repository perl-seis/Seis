requires 'perl', '5.018000';

requires 'Exception::Tiny';
requires 'Perl6::PVIP', 0.07;
requires 'autobox', 2.79;
requires 'Caroline';
requires 'Class::XSAccessor', 1.16;
requires 'Math::BaseCnv';
requires 'Sub::Name';
requires 'Math::Prime::Util';
requires 'Time::HiRes';
requires 'Math::BigInt';
requires 'Encode';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

