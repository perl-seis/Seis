package Rokugo::Exceptions;
use strict;
use warnings;
use utf8;
use 5.010_001;

package Rokugo::Exception::ParsingError;
use parent qw(Rokugo::Exception);

package Rokugo::Exception::NotImplemented;
use parent qw(Rokugo::Exception);

package Rokugo::Exception::UnknownNode;
use parent qw(Rokugo::Exception);

package Rokugo::Exception::CompilationFailed;
use parent qw(Rokugo::Exception);

package Rokugo::Exception::ArgumentCount;
use parent qw(Rokugo::Exception);

1;

