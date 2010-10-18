package App::gh::Command::Pull;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh::Utils;
use LWP::Simple qw(get);
use JSON;

=head1 NAME

App::gh::Command::Pull - pull changes from other forks.

=head1 USAGE

First you show up all fork network:

    $ gh network

Then you can pull changes from one:

    $ gh pull [id] (from branch) (to branch)

For example:

    $ gh pull gugod

This will create a gugod-master branch:

=cut

sub options { (
        "m|merge" => "merge",
        "b|branch" => "branch",
        "verbose" => "verbose",

        "ssh" => "protocal_ssh",    # git@github.com:c9s/repo.git
        "http" => "protocal_http",  # http://github.com/c9s/repo.git
        "https" => "https",         # https://github.com/c9s/repo.git
        "git|ro"   => "git"         # git://github.com/c9s/repo.git
    ) }

sub run {
    my ( $self, $acc, $from_branch, $to_branch ) = @_;

    die "require user id" unless $acc;

    $from_branch ||= 'master';
    $to_branch   ||= $from_branch;

    if( qx(git diff) ) {
        die "Your repository is diryt\n";
    }

    die "git config not found." if  ! -e ".git/config" ;

    my $fork_branch_name = "$acc-$from_branch";
    my $current_repo = $self->get_current_repo();
    my $fork_uri = $self->gen_uri( $acc , $current_repo );

    unless( qx(git remote | grep $acc ) ) {
        print "Adding remote [$acc] for [$fork_uri]\n";
        qx(git remote add $acc $fork_uri);
    }

    print "Fetching $acc ...\n";
    qx(git fetch $acc);

    if( $self->{merge} ) {
        print "Checking out $to_branch ...\n";
        qx(git checkout $to_branch);

        print "Merging changes from [$acc/$from_branch] to $to_branch\n";
        qx(git merge $acc/$from_branch);
    }
    print "Done\n";
}

1;
