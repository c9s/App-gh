package App::gh;

use warnings;
use strict;

use MooseX::App qw/ ConfigHome Color /;

with 'App::gh::API';

app_namespace 'App::gh::Command';

__PACKAGE__->meta->make_immutable;

__END__
