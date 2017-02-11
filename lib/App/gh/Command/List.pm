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

use experimental 'switch', 'postderef';

parameter username => (
    is       => 'ro',
    required => 1,
);

option format => (
    is => 'ro',
    isa => enum([ qw/ summary json / ]),
    default => 'summary',
    documentation => 'printing format',
);

# TODO move into a role
    # with 'App::gh::Role::Formats' => { 
    # first one is the default
    #     formats => [ 'json', 'summary' ],
    # };

sub print_formatted {
    my $self = shift;
    my $method = 'print_' . $self->format;
    $self->$method(@_);
}

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

use IO::Interactive qw/ is_interactive /;

has handlebars => (
    is => 'ro',
    lazy => 1,
    default => sub {
        use_module( 'Text::Handlebars' )->new(
            helpers => {
                color => sub {
                    my( $context, $color, $options ) = @_;
                    my $output = $options->{fn}->($context)||'';
                    return is_interactive() ?  colored( [ $color ], $output ) : $output;
                },
                pad => sub {
                    my( $context, $padding, $options ) = @_;
                    return sprintf "%${padding}s", $options->{fn}->($context);
                },
            }
        );
    },
    handles => [ 'render_string' ],
);


sub print_json {
    my( undef, $data ) = @_;
    print to_json $data, { pretty => 1, canonical => 1, allow_blessed => 1 };
}

sub run {
    my $self = shift;

    my @repos = $self->list_user_repos( $self->username );

    $self->print_formatted(\@repos);

}


1;

