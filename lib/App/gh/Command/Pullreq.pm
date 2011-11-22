package App::gh::Command::Pullreq;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh;
use App::gh::Utils;

use constant subcommands => qw(List Show Send);

=head1 NAME

App::gh::Command::Pullreq - pull request. (show/list/send)

=head1 USAGE

Send a pull request

before that, make sure you've set EDITOR environment variable.

    $ gh pullreq send

List pull requests

    $ gh pullreq list
    ...

Show pull requests issue {N}:

    $ gh pullreq show {N}

=cut

sub run {
    my ($self, @args) = @_;
    $self->global_help unless @args;
}

1;
