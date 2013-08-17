package Rokugo::Exceptions;
use strict;
use warnings;
use utf8;
use 5.010_001;

package Rokugo::Exception::ParsingError;
use parent qw(Exception::Tiny);

package Rokugo::Exception::NotImplemented;
use parent qw(Exception::Tiny);

package Rokugo::Exception::UnknownNode;
use parent qw(Exception::Tiny);

package Rokugo::Exception::CompilationFailed;
use parent qw(Exception::Tiny);

1;

