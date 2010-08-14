package App::gh::Command::Pull;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh::Utils;
use LWP::Simple qw(get);
use JSON;


sub parse_remote_param {
    my $uri = shift;
    if ( $uri =~ m{(?:git|https?)://github.com/(.*?)/(.*?).git} 
        || $uri =~ m{git\@github.com:(.*?)/(.*?).git} ) 
    {
        return ( $1 , $2 )
            if( $1 && $2 );
    }
    return undef;
}

sub run {
    my $self = shift;
    my $acc  = shift;
    my $branch = shift || 'master';

    die "git config not found." if  ! -e ".git/config" ;
    my $config = parse_config( ".git/config" );

    # git://github.com/miyagawa/Tatsumaki.git
    for my $remote ( values %{ $config->{remote} } ) {
        if( my ($my, $repo) = parse_remote_param( $remote->{url} ) )
        {
            my $uri = sprintf( qq(git://github.com/%s/%s.git) , $my , $repo );
            qx(git pull $uri $branch);
            last;
        }
    }
}

1;
