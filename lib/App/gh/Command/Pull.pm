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

=head1 OPTIONS

    --branch 
    
    create tracked branch for fork.

    --merge

    merge changes from fork.

=head3 Github Steps:

Step 1: Check out a new branch to test the changes — run this from your project directory

    git checkout -b chocolateboy-optional_dep_and_warnings_fixes master

Step 2: Bring in chocolateboy's changes and test

    git pull http://github.com/chocolateboy/App-gh.git optional_dep_and_warnings_fixes

Step 3: Merge the changes and update the server

    git checkout master
    git merge chocolateboy-optional_dep_and_warnings_fixes
    git push origin master

=cut

sub options { (
        "m|merge"  => "merge",
        "b|branch" => "branch",
        "verbose"  => "verbose",
        "ssh"      => "protocal_ssh",    # git@github.com:c9s/repo.git
        "http"     => "protocal_http",  # http://github.com/c9s/repo.git
        "https"    => "https",         # https://github.com/c9s/repo.git
        "git|ro"   => "git"         # git://github.com/c9s/repo.git
    ) }

sub run {
    my ( $self, $acc, $from_branch, $to_branch ) = @_;

    unless ( $acc ) {
        print "Usage: \n";
        print "     gh pull [userid] (from branch) (to branch)\n\n";



        my $origin_url = qx( git remote -v | grep origin | grep fetch );
        my ($userid,$repo) = ($origin_url =~ m{:(\w+)/(.*?)\.git});

        print "Available forks:\n";

        # XXX: refactor this ... XD
        my $objs = App::gh->api->request(qq(repos/show/$userid/$repo/network));
        my $networks = $objs->{network};
        for my $net ( @$networks ) {
            print sprintf( "% 20s - watchers(%d) forks(%d)\n"
                , $net->{owner} . '/' . $net->{name}
                , $net->{watchers}
                , $net->{forks}
                );
        }
        print "\n";
        return;
    }

    $from_branch ||= 'master';
    $to_branch   ||= 'master';

    if( qx(git diff) ) {
        die "Your repository is diryt\n";
    }

    die "git config not found." if  ! -e ".git/config" ;

    my $remote_name      = $acc;
    my $fork_branch_name = "$acc-$from_branch";
    my $current_repo     = $self->get_current_repo();
    my $fork_uri         = $self->gen_uri( $acc , $current_repo );

    unless( qx(git remote | grep $remote_name ) ) {
        print "Adding remote [$remote_name] for [$fork_uri]\n";
        qx(git remote add $remote_name $fork_uri);
    }

    print "Fetching $acc ...\n";
    print qx(git fetch $acc);


    if( $self->{merge} ) {
        print "Checking out $to_branch ...\n";
        qx(git checkout $to_branch);

        print "Merging changes from [$acc/$from_branch] to $to_branch\n";
        print qx(git merge $acc/$from_branch);
    }

    if( $self->{branch} ) {
        print "Creating track branch for $acc/$from_branch\n";
        print qx(git checkout --track -b $fork_branch_name $acc/$from_branch);
    }

    print "Done\n";
}

1;
