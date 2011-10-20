package App::gh::Command::Issue;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh;
use App::gh::Utils;

use constant subcommands => qw(List Show Edit Comment);

=head1 NAME

App::gh::Command::Issue - issues. (show/list/edit/comment)

=head1 DESCRIPTION

balh

=cut

sub run {
    my ($self, @args) = @_;
    $self->global_help unless @args;
}

1;
