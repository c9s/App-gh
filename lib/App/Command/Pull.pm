package App::Command::Pull;
use warnings;
use strict;
use base qw(App::gh::Command);

sub run {
    my $self = shift;
    my $acc  = shift;
    my $branch = shift || 'master';

    die "git config not found." if  ! -e ".git/config" ;
    my $config = parse_config( ".git/config" );

    # git://github.com/miyagawa/Tatsumaki.git
    for my $remote ( values %{ $config->{remote} } ) {
        if ( $remote->{url} =~ m{git://github.com/(.*?)/(.*?).git} 
            || $remote->{url} =~ m{git\@github.com:(.*?)/(.*?).git} ) 
        {
            my ( $my, $repo ) = ( $1, $2 );
            my $uri = sprintf( qq(git://github.com/%s/%s.git) , $acc , $repo );
            qx(git pull $uri $branch);
            last;
        }
    }
}

1;
