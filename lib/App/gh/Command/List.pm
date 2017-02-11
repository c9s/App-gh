package App::gh::Command::List;
# ABSTRACT: list a user's repositories

use 5.10.0;

use warnings;
use strict;

use MooseX::App::Command;

use Moose::Util::TypeConstraints qw/ enum /;
use Module::Runtime qw/ use_module /;

use Term::ANSIColor qw/ colored /;
use JSON qw/ to_json /;

extends 'App::gh';
with 'App::gh::Role::Format' => {
    formats => [qw/ summary json /],
};

use experimental 'switch', 'postderef';

parameter username => (
    is       => 'ro',
    required => 1,
);

sub print_summary {
    my( $self, $repos ) = @_;

    say $self->render_string( $self->summary_entry, $_) 
        for @$repos;
};

# TODO read again if there are more

# TODO turn into option
has summary_entry => (
    is => 'ro',
    default => '{{#color "blue"}}{{#pad "-30"}}{{ name }}{{/pad}}{{/color}} - {{ description }}'
);

sub run {
    my $self = shift;

    my @repos = $self->list_user_repos( $self->username );

    $self->print_formatted(\@repos);

}


1;

