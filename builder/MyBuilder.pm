package builder::MyBuilder;
use strict;
use warnings;
use utf8;

use parent qw(Module::Build);
use File::Copy;
use Config;

sub ACTION_code {
    my ($self) = @_;

    $self->process_PL_files;

    {
        my $b = $self->cbuilder();

        my $obj_file = $b->compile(
            source               => 'bin/seis.c',
        );
        my $exe_file = $b->link_executable(objects => $obj_file);

        # script_files is set here as the resulting compiled
        # executable name varies based on operating system
        $self->script_files($exe_file);

        # Cleanup files from compilation
        $self->add_to_cleanup($obj_file, $exe_file);
    }

    $self->SUPER::ACTION_code();
}

1;

