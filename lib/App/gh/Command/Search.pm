package App::gh::Command::Search;
# ABSTRACT: search repositories

use 5.10.0;

use warnings;
use strict;

use MooseX::App::Command;

use Moose::Util::TypeConstraints qw/ enum /;
use Module::Runtime qw/ use_module /;

use Term::ANSIColor qw/ colored /;

extends 'App::gh';

with 'App::gh::Role::Format' => {
    formats => [qw/ summary json /],
};

use experimental 'switch', 'postderef';

parameter query => (
    is => 'ro',
    documentation => 'search query',
);

option sort => (
    is => 'ro',
    default => 'popularity',
    documentation => 'sorting criteria',
);

option reverse => (
    is            => 'ro',
    isa           => 'Bool',
    default       => sub { 0 },
    documentation => 'list entries in descending order',
);



sub run {
    my $self = shift;

    my %repos = $self->search_repositories({ 
        q     => $self->query,
        sort  => $self->sort,
        order => $self->reverse ? 'desc' : 'asc'
    });

    $self->print_formatted(\%repos);

}

# TODO turn into option
has summary_entry => (
    is => 'ro',
    default => '{{#color "blue"}}{{#pad "-30"}}{{ full_name }}{{/pad}}{{/color}} - {{ description }}'
);

sub print_summary {
    my( $self, $repos ) = @_;
    my $template = $self->summary_entry;

    say $self->render_string( $self->summary_entry(), $_) 
        for $repos->{items}->@*;
}


=encoding utf8

=head1 USAGE

    $ gh search --sort popularity --reverse perl6

=cut

# search --reverse (desc) --sort

# three format options short, or verbose, or json

# color if interactive, strip'em if not
# template for entries

# Term::ANSIColor
# IO::Interactive
# Text::Balanced

# allow to config color aliases

#    !blue on_red<$_{username} }/$_{name}>



1;
__END__

Entry structure

    {
        'size' => 120,
        'watchers' => 228,
        'created_at' => '2010/09/18 05:38:07 -0700',
        'url' => 'https://github.com/Marak/webservice.js',
        'followers' => 228,
        'open_issues' => 16,
        'owner' => 'Marak',
        'has_downloads' => $VAR1->{'repositories'}[0]{'has_issues'},
        'has_issues' => $VAR1->{'repositories'}[0]{'has_issues'},
        'language' => 'JavaScript',
        'pushed' => '2011/09/29 15:22:44 -0700',
        'name' => 'webservice.js',
        'private' => $VAR1->{'repositories'}[0]{'has_downloads'},
        'score' => '0.48941568',
        'has_wiki' => $VAR1->{'repositories'}[0]{'has_issues'},
        'description' => ' turn node.js modules into RESTFul web-services',
        'pushed_at' => '2011/09/29 15:22:44 -0700',
        'username' => 'Marak',
        'forks' => 21,
        'created' => '2010/09/18 05:38:07 -0700',
        'homepage' => 'http://blog.nodejitsu.com/create-nodejs-web-services-in-one-line',
        'fork' => $VAR1->{'repositories'}[0]{'has_downloads'},
        'type' => 'repo'
    },

