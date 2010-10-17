package App::gh::Command::Pull;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh::Utils;
use LWP::Simple qw(get);
use JSON;

=head1 NAME

App::gh::Command::Pull - pull changes from other forks.

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

    my $fork_branch_name = "$acc/$from_branch";
    my $current_repo = $self->get_current_repo();
    my $fork_uri = $self->gen_uri( $acc , $current_repo );

    if( $self->{merge} ) {
        print "Merging changes from [$fork_uri / $from_branch] to $to_branch\n";
        qx(git checkout $to_branch);
        qx(git pull $fork_uri $from_branch);
    }


    # check if fork branch exists
    unless( qx(git branch | grep $fork_branch_name) ) {
        print "Creating branch $fork_branch_name from $to_branch...\n";
        qx(git branch $fork_branch_name $to_branch);
    }

    print "Checking out $fork_branch_name\n";
    qx(git checkout $fork_branch_name );

    print "Pulling changes from [$fork_uri]\n";
    qx(git pull $fork_uri $from_branch);

    print "Adding remote [$acc] for [$fork_uri]\n";
    qx(git remote add $acc $fork_uri);

    print "Done\n";
}

1;
