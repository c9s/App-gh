package App::gh::Command::Network;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh;
use App::gh::Utils;

=head1 NAME

App::gh::Command::Network - show network

=head1 USAGE

    $ cd App-gh
    $ gh network

=cut


sub options { (
        'i|id' => 'id_only',  # id only
    ) }

sub require_local_gitconfig { 1 }



sub get_networks {
    my $config = App::gh->config->current();
    my ( $name, $url ) = split( /\s+/, qx( git remote -v | grep origin | grep push ) );

    # git://github.com/miyagawa/Tatsumaki.git
    if ( $url && ( $url =~ m{git://github.com/(.*?)/(.*?).git}
            || $url =~ m{git\@github.com:(.*?)/(.*?).git} ) ) {

        my ( $acc, $repo ) = ( $1, $2 );
        return App::gh->api->repo_network( $acc , $repo );
    }
}

sub run {
    my $self = shift;
    my $networks = $self->get_networks;
    for my $net ( @$networks ) {
        if( $self->{id_only} ) {
            print $net->{owner} . "\n";
        }
        else {
            printf( "% 17s - watchers(%d) forks(%d)\n"
            , $net->{owner} . '/' . $net->{name}
            , $net->{watchers}
            , $net->{forks}
            );
        }
    }
}

1;
