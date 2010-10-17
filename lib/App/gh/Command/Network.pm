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

sub require_local_gitconfig { 1 }

sub run {
    my $config = parse_config( ".git/config" );
    for my $remote ( values %{ $config->{remote} } ) {
        # git://github.com/miyagawa/Tatsumaki.git
        if ( $remote->{url} =~ m{git://github.com/(.*?)/(.*?).git} 
            || $remote->{url} =~ m{git\@github.com:(.*?)/(.*?).git} ) 
        {
            my ($acc,$repo) = ($1,$2);

            my $objs = api_request(qq(repos/show/$acc/$repo/network));
            my $networks = $objs->{network};
            for my $net ( @$networks ) {
                _info sprintf( "% 17s - watchers(%d) forks(%d)"
                    , $net->{owner} . '/' . $net->{name}
                    , $net->{watchers}
                    , $net->{forks}
                    );
            }
            last;
        }
    }
}

1;
