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

Git Options:

    -b | --branch    clone specific branch.

    --recursive, --recurse-submodules

        After the clone is created, initialize all submodules within, using their default settings.
        This is equivalent to running git submodule update --init --recursive immediately after the
        clone is finished. This option is ignored if the cloned repository does not have a
        worktree/checkout (i.e. if any of --no-checkout/-n, --bare, or --mirror is given)

        See `git help clone`

=cut

sub options { (
    "verbose" => "verbose",
    "ssh" => "protocol_ssh",    # git@github.com:c9s/repo.git
    "http" => "protocol_http",  # http://github.com/c9s/repo.git
    "https" => "protocol_https",         # https://github.com/c9s/repo.git
    "git|ro"   => "protocol_git",        # git://github.com/c9s/repo.git
    "k|forks|fork"  => 'with_fork',
    "b|bare" => "bare",
    "b|branch=s" => "branch",
    "recursive"  => "recursive",
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

    my @command = qw(git clone);
    push @command, '--bare' if $self->{bare};
    push @command, '--branch=' . $self->{branch} if $self->{branch};
    push @command, '--recursive' if $self->{recursive};
    push @command, $uri;

    print 'Cloning ', $uri,  "...\n";
    system( join ' ', @command );

    # fetch with fork
    if( $self->{with_fork} ) {
        my $dirname = basename($uri,'.git');

        # get networks
        my $repos = App::gh->github->repos->set_default_user_repo($user,$repo);
        my @forks = $repos->forks;

        if( @forks ) {
            print "Found " , scalar(@forks) , " forks to fetch...\n";
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
