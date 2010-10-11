package App::gh::Command::Pull;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh::Utils;
use LWP::Simple qw(get);
use JSON;

sub options { (
        "m|merge" => "merge",
        "verbose" => "verbose",

        "ssh" => "protocal_ssh",    # git@github.com:c9s/repo.git
        "http" => "protocal_http",  # http://github.com/c9s/repo.git
        "https" => "https",         # https://github.com/c9s/repo.git
        "git|ro"   => "git"         # git://github.com/c9s/repo.git
    ) }

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

sub get_current_repo {
    my $self = shift;
    my $config = parse_config( ".git/config" );
    for my $remote ( values %{ $config->{remote} } ) {
        if( my ($my, $repo) = parse_remote_param( $remote->{url} ) )
        {
            return ($my,$repo);
        }
    }

}

sub run {
    my ($self,$acc,$branch) = @_;

    $branch ||= 'master';

    die "git config not found." if  ! -e ".git/config" ;


    # check if fork branch exists
    my $fork_branch_name = "$acc/$branch";
    unless( qx(git branch | grep $fork_branch_name) ) {
        print "Creating fork branch $fork_branch_name...\n";
        qx(git branch $fork_branch_name master);
    }

    my $current_repo = $self->get_current_repo();
    my $fork_uri = $self->gen_uri( $acc , $current_repo );
    my $uri = sprintf( qq(git://github.com/%s/%s.git) , $acc , $repo );

    print "Pulling changes from [$fork_uri]\n";
    qx(git pull $fork_uri $fork_branch_name);

    
    print "Adding remote [$acc] for [$fork_uri]\n";
    qx(git remote add $acc $fork_uri);

    print "Done\n";
}

1;
