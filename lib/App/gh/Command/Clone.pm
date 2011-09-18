package App::gh::Command::Clone;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh::Utils;
use App::gh;

=head1 NAME

App::gh::Command::Clone - clone repository

=head1 DESCRIPTION

balh

=head1 OPTIONS

    --verbose
    --ssh
    --http
    --https
    --git|ro
    -k | --forks     also fetch forks.


=cut

sub options { (
    "verbose" => "verbose",
    "ssh" => "protocol_ssh",    # git@github.com:c9s/repo.git
    "http" => "protocol_http",  # http://github.com/c9s/repo.git
    "https" => "protocol_https",         # https://github.com/c9s/repo.git
    "git|ro"   => "protocol_git",        # git://github.com/c9s/repo.git
    "k|forks|fork"  => 'with_fork',
    "bare" => "bare",
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
        die "Usage: gh clone [user] [repo]\n";
    }

    my $uri = $self->gen_uri( $user, $repo );
    my $flags = q{};
    $flags .= qq{ --bare } if $self->{bare};

    print 'cloning ', $uri,  "...\n";
    system( qq{git clone $flags $uri} );

    if( $self->{with_fork} ) {
        my ( $dirname ) = ( $uri =~ m/([a-zA-Z0-9-]+)\.git$/ );
        chdir $dirname;

        # get networks
        my $networks = App::gh->api->repo_network( $user , $repo );
        for my $net ( @$networks ) {
            my $acc = $net->{owner};
            my $url = $net->{url};

            print qq{Adding remote $acc => $url.git\n};
            qx(git remote add $acc $url.git);

            print qq{Fetching remote $acc\n};
            qx(git fetch $acc);
        }
    }
}

1;
