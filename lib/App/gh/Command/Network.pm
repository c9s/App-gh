package App::gh::Command::Network;
use warnings;
use strict;
use base qw(App::gh::Command);
use LWP::Simple;
use JSON;
use App::gh::Utils;

sub require_local_gitconfig { 1 }


sub run {
    my $config = parse_config( ".git/config" );
    for my $remote ( values %{ $config->{remote} } ) {
        # git://github.com/miyagawa/Tatsumaki.git
        if ( $remote->{url} =~ m{git://github.com/(.*?)/(.*?).git} 
            || $remote->{url} =~ m{git\@github.com:(.*?)/(.*?).git} ) 
        {
            my ($acc,$repo) = ($1,$2);
            # curl http://github.com/api/v2/yaml/repos/show/schacon/ruby-git/network
            my $url = qq(http://github.com/api/v2/json/repos/show/$acc/$repo/network);
            my $json = get $url;
            my $objs = decode_json($json);
            # use Data::Dumper; warn Dumper( $objs );
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
