package App::gh::API;

use warnings;
use strict;
use Net::GitHub::V3;

use Moose::Role;

use PerlX::Maybe;

has api => (
    is	    => 'ro',
    lazy => 1,
    default => sub {
        Net::GitHub::V3->new( maybe ua => $_[0]->api_ua );
    },
    handles => [ 'search' ],
);

has api_ua => (
    is => 'ro',
    lazy => 1,
    default => sub { $App::gh::TEST_UA },
);



sub search_repositories {
    my( $self, $args ) = @_;

    $self->search->repositories($args);
}

1;
