package App::gh::Utils;
use warnings;
use strict;
use base qw(Exporter);

use constant debug => $ENV{DEBUG};

our @EXPORT = qw(_debug _info);

sub _debug {
    print STDERR @_,"\n" if debug;
}

sub _info {
    print STDERR @_,"\n";
}

1;
