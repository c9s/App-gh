package App::gh::Command::Pullreq;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh;
use App::gh::Utils;

use constant subcommands => qw(List Show Send);

=head1 NAME

App::gh::Command::Pullreq - pull request. (show/list/send)

=head1 DESCRIPTION

balh

=cut

sub run {
    my ($self, @args) = @_;
    $self->global_help unless @args;
}

1;
