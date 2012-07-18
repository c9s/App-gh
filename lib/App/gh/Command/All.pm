package App::gh::Command::All;
use utf8;
use warnings;
use strict;
use base qw(App::gh::Command);
use File::Path qw(mkpath rmtree);
use App::gh::Utils qw(
    info 
    error
    notice
    generate_repo_uri 
    run_git_fetch
    build_git_clone_command
    dialog_yes_default
);
use Scope::Guard qw(guard);
use Cwd ();

sub options { (
        "verbose"       => "verbose",
        "prompt"        => "prompt",
        "into=s"        => "into",
        "exclude=s@"    => "exclude",
        "s|skip-exists" => "skip_exists",

        "ssh"    => "protocol_ssh",    # git@github.com:c9s/repo.git
        "http"   => "protocol_http",  # http://github.com/c9s/repo.git
        "https"  => "protocol_https",         # https://github.com/c9s/repo.git
        "git|ro" => "protocol_git",         # git://github.com/c9s/repo.git


        "tags"       => "tags",
        "q|quiet"    => "quiet",
        "bare"       => "bare",
        "mirror"     => "mirror",
        "b|branch=s" => "branch",
        "recursive"  => "recursive",
        "origin"     => "origin",


        "p|prefix=s" => "prefix",
        "f|force" => "force",
    ) }


# 
# @param string $user github user id
# @param string $type github repository type (all,owner,member,all)
# @see http://developer.github.com/v3/repos/

sub run {
    my $self = shift;
    my $user = shift;
    my $type = shift || 'owner';

    # turn off buffering
    $|++; 

    my $cwd = Cwd::getcwd();
    $self->{into} ||= $user;

    die 'Need account id.' unless $user;

    if( $self->{into} ) {
        info "Cloning all repositories into @{[ $self->{into} ]}";
        mkpath [ $self->{into} ];
        chdir  $self->{into};
    }

    info "Getting repositories from $user...";
    my @repos = App::gh->github->repos->list_user($user,$type);

    unless(@repos) {
        info "Found no repository to clone, exiting";
        return;
    }

    my $into = Cwd::getcwd();
    my $cloned = 0;
    my $total = scalar(@repos);

    info "Found " . $total . " repositories to clone:";
    print " " x 8 . join " " , map { $_->{name} } @repos;
    print "\n";

    return unless dialog_yes_default "Are you sure to continue ?";

    my $progress = sub {
        return sprintf "[%d/%d]",
            ++$cloned,
            $total;
    };

    my $exclude = do {
        my $arr = ref $self->{exclude} eq 'ARRAY' ? $self->{exclude} : [];
        +{map { $_ => 1 } @$arr};
    };

    for my $repo ( @repos ) {
        my $local_repo = $repo->{name};

        next if exists $exclude->{ $local_repo };

        my $uri = generate_repo_uri($user,$repo->{name},$self);
        my @command = build_git_clone_command($uri,$self);
        $local_repo = $self->{prefix} . $local_repo if $self->{prefix};
        push @command , $local_repo;

        if( -e $local_repo) {
            if( $self->{skip_exists} ) {
                info "Found $local_repo, skip.";
                next;
            }
            elsif( $self->{force} ) {
                notice "Force mode, Deleting original $local_repo";
                rmtree $local_repo or do {
                    error "Could not remove '$local_repo', skip.\n";
                    next;
                };
            } 
            else {
                # fetch and jump to next
                info $progress->() . " $local_repo exists, fetching...";
                chdir($local_repo);
                run_git_fetch {
                    all => 1, 
                    quiet => $self->{quiet},
                    tags => $self->{tags},
                };
                chdir($into);
                next;
            }
        }

        if( $self->{prompt} ) {
            next unless dialog_yes_default "Clong " . $repo->{name} . ' ?';
        }

        info sprintf "%s Cloning %s (%d/%d) ...", 
            $progress->(),
            $repo->{full_name},
            $repo->{watchers},
            $repo->{forks};
        my $cmd = join " ",@command;
        qx($cmd);

        if( $self->{tags} ) {
            chdir $local_repo;
            run_git_fetch { 
                all => 1, 
                quiet => $self->{quiet},
                tags => $self->{tags},
            };
            chdir $into;
        }

    }

=pod

    for my $repo ( @{ $repolist } ) {
        # =================
        # End of conditions for skipping clone


        if( -e $local_repo_dir ) {
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
                qx{git remote update --prune};

                # fetch all remotes
                qx{ git fetch --all };

                # update current working repo
                qx{ git pull $flags --rebase --all };
            }
        }
        else {
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
=cut

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
