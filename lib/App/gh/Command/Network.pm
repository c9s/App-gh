package App::gh::Command::Network;
use warnings;
use strict;
use base qw(App::gh::Command);
use LWP::Simple;
use JSON;
use App::gh::Utils;

=head1 NAME

App::gh::Command::Network - show network

=cut


sub options { (
        'i|id' => 'id_only',  # id only
    ) }

sub require_local_gitconfig { 1 }

use App::gh;

sub run {
    my $self = shift;
    my $networks = App::gh->get_networks;
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
