package Hybrid::Exceptions;
use strict;
use warnings;
use utf8;
use 5.010_001;

package Hybrid::Exception::ParsingError;
use parent qw(Exception::Tiny);

package Hybrid::Exception::NotImplemented;
use parent qw(Exception::Tiny);

package Hybrid::Exception::UnknownNode;
use parent qw(Exception::Tiny);


1;

