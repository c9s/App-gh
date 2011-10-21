package App::gh::Command::All;
use utf8;
use warnings;
use strict;
use base qw(App::gh::Command);
use File::Path qw(mkpath rmtree);
use App::gh::Utils;
use Scope::Guard qw(guard);
use Cwd ();

sub options { (
        "verbose" => "verbose",
        "prompt"  => "prompt",
        "into=s"  => "into",
        "exclude=s@" => "exclude",
        "s|skip-exists" => "skip_exists",

        "ssh" => "protocol_ssh",    # git@github.com:c9s/repo.git
        "http" => "protocol_http",  # http://github.com/c9s/repo.git
        "https" => "protocol_https",         # https://github.com/c9s/repo.git
        "git|ro"   => "protocol_git",         # git://github.com/c9s/repo.git

        "skip-forks" => "skip_forks",  # skip repositories fork from others.

        "bare" => "bare",
        "mirror" => "mirror",
        "p|prefix=s" => "prefix",
        "f|force" => "force",
    ) }


sub run {
    my $self = shift;
    my $acc  = shift;

    # turn off buffering
    $|++; 

    $self->{into} ||= $acc;

    die 'Need account id.' unless $acc;

    _info "Getting repository list from github: $acc";

    my $repolist = App::gh->api->user_repos( $acc );
    return if @$repolist == 0;

    if( $self->{into} ) {
        print STDERR "Cloning all repositories into @{[ $self->{into} ]}\n";
        mkpath [ $self->{into} ];
        chdir  $self->{into};
    }

    $self->{bare} = 1 if $self->{mirror};


    _info "Will clone repositories below:";
    print " " x 8 . join " " , map { $_->{name} } @{ $repolist };
    print "\n";

    _info "With options:";
    _info " Prefix: " . $self->{prefix} if $self->{prefix};
    _info " Bare: on" if $self->{bare};
    _info " Mirror: on" if $self->{mirror};

    my $exclude = do {
        my $arr = ref $self->{exclude} eq 'ARRAY' ? $self->{exclude} : [];
        +{map { $_ => 1 } @$arr};
    };

    my $cloned = 0;

    my $print_progress = sub {
        return sprintf( "[%d/%d]", ++$cloned , scalar(@$repolist) );
    };

    for my $repo ( @{ $repolist } ) {
        my $repo_name      = $repo->{name};
        my $uri            = $self->gen_uri( $acc, $repo_name );
        my $local_repo_dir = $repo_name;
        $local_repo_dir    = "$local_repo_dir.git" if $self->{bare};
        $local_repo_dir    = $self->{prefix} . "-" . $local_repo_dir if $self->{prefix};

        print $uri . "\n" if $self->{verbose};

        # ===> Conditions for skipping repos, to prevent api rate exceeded
        if( $self->{prompt} ) {
            print "Clone $repo_name [Y/n] ? ";
            my $ans = <STDIN>;
            chomp( $ans );
            $ans ||= 'Y';
            next if( $ans =~ /n/ );
        }

        next if exists $exclude->{$repo_name};

        if( $self->{skip_exists} ) {
            # Found local repository. Update it.
            if(-e $local_repo_dir) {
                _info "Found $local_repo_dir, skipped.";
                next;
            }
        }

        if( $self->{skip_forks} ) {
            # NOTICE: This might exceed the API rate, careful.
            # Please put this to the end of condition.
            my $info = App::gh->api->repo_info( $acc , $repo_name );
            if($info->{parent}) {
                _info "Skipping repository with parent: $repo_name";
                next;
            }
        }

        # =================
        # End of conditions for skipping clone


        if( -e $local_repo_dir ) {

            if( $self->{force} ) {
                rmtree $local_repo_dir or do {
                    print STDERR "could not remove '$local_repo_dir', skipped.\n";
                    next;
                };
            }

            my $cwd = Cwd::getcwd();
            chdir $local_repo_dir;
            my $guard = guard { chdir $cwd };    # switch back
            print "Updating $local_repo_dir from remotes ..." . $print_progress->() . "\n";

            if( qx{ git config --get core.bare } =~ /\Atrue\n?\Z/ ) {
                # Here I assume remote.<remote>.mirror is automatically set.
                # bacause --bare and --mirror do the set-up.
                qx{ git fetch --all };
            }
            else {
                my $flags = qq();
                $flags .= qq{ -q } unless $self->{verbose};

                # prune deleted remote branches
                qx{ git remote update --prune };

                # fetch all remotes
                qx{ git fetch --all };

                # update current working repo
                qx{ git pull $flags --rebase --all };
            }
        }
        else {
            # No repository was cloned yet. Clone it.
            _info "Cloning " . $repo->{name} . " ... " . $print_progress->();

            my $flags = qq();
            $flags .= qq{ -q }     unless $self->{verbose};
            $flags .= qq{ --bare } if     $self->{bare};

            my $cmd = qq{ git clone $flags $uri $local_repo_dir};
            qx{ $cmd };

            # Support old git (which does not support `git clone --mirror`)
            if ($self->{mirror}) {
                my $cwd = Cwd::getcwd();
                chdir $local_repo_dir;
                my $guard = guard { chdir $cwd };    # switch back
                qx{ git config remote.origin.fetch '+refs/*:refs/*' };
                qx{ git config remote.origin.url $uri };
                qx{ git config remote.origin.mirror true };
            }
        }
    }
    print "Done\n";
}


1;
__END__

=head1 NAME

App::gh::Command::All - clone/update all repositories from one

=head1 DESCRIPTION

If you need a mirror of repos from one, you will need this command.

If repos exists, clone command will pull changes for these repos from remotes.

=head1 USAGE

    $ mkdir github
    $ cd github

To clone c9s' repos:

    $ gh all c9s

Once you have all repos cloned, to update them, you only need to run all
command again:

    $ gh all c9s

=head1 OPTIONS

Genernal Options:

    --prompt
        prompt for each cloning repo.

    --into {path}
        clone repos into a {path}.

    --skip-forks
        skip repos which has a parent repo (fork from others)

    --skip-exists, -s
        skip existed repos.

    --verbose
        verbose output.

    --bare
        clone repos as bare repos.
        this option adds postfix ".git" to directory.
        e.g.: "{dirname}.git"

    --mirror
        clone repos as mirror repos.
        this option adds postfix ".git" to directory.
        e.g.: "{dirname}.git"

    --prefix {prefix}
        Add prefix to repository name.

    --force, -f
        remove existed repos before cloning repos.

Clone URL format:

    --ssh

    --http

    --https

    --git

=cut
