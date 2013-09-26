requires 'perl', '5.018000';

requires 'Exception::Tiny';
requires 'autobox', 2.79;
requires 'Caroline';
requires 'Class::XSAccessor', 1.16;
requires 'Math::BaseCnv';
requires 'Sub::Name';
requires 'Math::Prime::Util';
requires 'Time::HiRes';
requires 'Math::BigInt';
requires 'Encode';
requires 'Sub::Identify';
requires 'File::ShareDir', '1.00';
requires 'Path::Tiny', '0.035';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

