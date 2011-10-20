package App::gh::Command;
use warnings;
use strict;
use App::gh;
use App::gh::Config;
use App::gh::API;
use App::gh::Utils;
use base qw(App::CLI App::CLI::Command);

use constant global_options => ( 'help' => 'help' );

sub alias { (
        "a"  => "all",
        "up"  => "update",
        "pu" => "pull",
        "fo"  => "fork",
        "ne"  => "network",
        "se"  => "search",
        "ci"  => "commit",
        ) }

sub invoke {
    my ($pkg, $cmd, @args) = @_;
    local *ARGV = [$cmd, @args];
    my $ret = eval {
        $pkg->dispatch();
    };
    if( $@ ) {
        warn $@;
    }
}

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
	my $config = App::gh->config->current();
    for my $remote ( values %{ $config->{remote} } ) {
        if( my ($my, $repo) = parse_remote_param( $remote->{url} ) )
        {
            return ($my,$repo);
        }
    }
}


sub gen_uri {
    my ($self,$acc,$repo) = @_;

    if( $self->{protocol_git} ) {
        return sprintf( 'git://github.com/%s/%s.git', $acc, $repo );
    }
    elsif( $self->{protocol_ssh} || $self->is_mine($acc, $repo) ) {
        return sprintf( 'git@github.com:%s/%s.git' , $acc, $repo );
    }
    elsif( $self->{protocol_http} ) {
        return sprintf( 'http://github.com/%s/%s.git' , $acc , $repo );
    }
    elsif( $self->{protocol_https}) {
        return sprintf( 'https://github.com/%s/%s.git' , $acc , $repo );
    }
    return sprintf( 'git://github.com/%s/%s.git', $acc, $repo );
}

sub is_mine {
    my($self, $acc, $repo) = @_;
    my $gh_user = App::gh->config->github_id;
    return defined($gh_user) && $gh_user eq $acc;
}

sub global_help {
    # XXX: scan command classes
    print <<'END';
App::gh


help
    - show help message

list [userid]
    - list all repository of an user:

clone [userid] [repo] ([http|ro|ssh])
    - clone repository from an user

search [keyword]
    - search repository:

all [userid]
    - to clone all repository of an user:

fork [userid] [repo]
    - to fork project:

fork
    - to fork current project:

network
    -  to show fork network:

pull [userid] ([branch])
    - pull from other's fork:

pullreq list
    - show list of pull requests:

pullreq show
    - show the pull requests:

pullreq send ([branch])
    - send pull requests of current branch to branch:

END
}

1;
