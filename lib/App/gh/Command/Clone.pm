package App::gh::Command::Clone;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh::Utils;
use LWP::Simple qw(get);
use App::gh::Utils;
use JSON;


sub options { (
    "verbose" => "verbose",
    "ssh" => "protocal_ssh",    # git@github.com:c9s/repo.git
    "http" => "protocal_http",  # http://github.com/c9s/repo.git
    "https" => "https",         # https://github.com/c9s/repo.git
    "git|ro"   => "git"         # git://github.com/c9s/repo.git
) }



sub run {
    my ($self) = shift;
    my $user;
    my $repo;

    $user = shift;
    if( $user =~ /\// ) {
        ( $user, $repo ) = split /\//, $user;
    }
    else {
        $repo = shift;
    }

    unless( $user && $repo ) {
        die "Usage [user] [repo]";
    }

    my $uri = $self->gen_uri( $user, $repo );
    print $uri . "\n";
    system( qq{git clone $uri} );
}

1;
