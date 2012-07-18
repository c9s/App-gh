package App::gh::Command::Clone;
use warnings;
use strict;
use base qw(App::gh::Command);
use File::Basename;
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
    my $self = shift;
    my $user = shift;
    my $repo;
    if( $user =~ /\// ) {
        ($user, $repo) = split /\//, $user;
    } else {
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


    # fetch with fork
    if( $self->{with_fork} ) {
        my $dirname = basename($uri,'.git');

        # get networks
        my $repos = App::gh->github->repos->set_default_user_repo($user,$repo);
        my @forks = $repos->forks;

        if( @forks ) {
            print "Found " , @forks , " forks to fetch...\n";
            chdir $dirname;
            for my $fork ( @forks ) {
                my ($full_name,$clone_url,$login) =
                        ($fork->{full_name},$fork->{clone_url},$fork->{owner}->{login});
                print qq{Adding remote $login => $clone_url\n};
                qx(git remote add $login $clone_url);
                print "Fetching fork $full_name...\n";
                qx(git fetch $login);
            }
        }
    }
}

1;
