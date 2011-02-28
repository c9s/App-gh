package App::gh::Command::All;
use utf8;
use warnings;
use strict;
use base qw(App::gh::Command);
use File::Path qw(mkpath rmtree);
use App::gh::Utils;
use LWP::Simple qw(get);
use JSON;
use Scope::Guard qw(guard);

sub options { (
        "verbose" => "verbose",
        "prompt" => "prompt",
        "into=s" => "into",
        "exclude=s@" => "exclude",
        "s|skip-exists" => "skip_exists",

        "ssh" => "protocal_ssh",    # git@github.com:c9s/repo.git
        "http" => "protocal_http",  # http://github.com/c9s/repo.git
        "https" => "https",         # https://github.com/c9s/repo.git
        "git|ro"   => "git",         # git://github.com/c9s/repo.git
        "bare" => "bare",
        "p|prefix=s" => "prefix",
        "f|force" => "force",
    ) }


sub run {
    my $self = shift;
    my $acc  = shift;


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

    _info "Will clone repositories below:";
    print " " x 8 . join " " , map { $_->{name} } @{ $repolist };
    print "\n";

    _info "With options:";
    _info " Prefix: " . $self->{prefix} if $self->{prefix};
    _info " Bare: on" if $self->{bare};

    if( $self->{prompt} ) {
        print "Clone them [Y/n] ? ";
        my $ans = <STDIN>;
        chomp( $ans );
        $ans ||= 'Y';
        return if( $ans =~ /n/ );
    }

    my $exclude = do {
        my $arr = ref $self->{exclude} eq 'ARRAY' ? $self->{exclude} : [];
        +{map { $_ => 1 } @$arr};
    };


    my $cloned = 0;

    my $print_progress = sub {  
        return sprintf( "[%d/%d]", ++$cloned , scalar(@$repolist) );
    };


    for my $repo ( @{ $repolist } ) {
        my $repo_name = $repo->{name};
        my $local_repo_name = $repo_name;
        $local_repo_name =~ s/\.git$//;

        if( $self->{prompt} ) {
            print "Clone $repo_name [Y/n] ? ";
            my $ans = <STDIN>;
            chomp( $ans );
            $ans ||= 'Y';
            next if( $ans =~ /n/ );
        }
        next if exists $exclude->{$local_repo_name};

        my $uri = $self->gen_uri( $acc, $repo_name );
        print $uri . "\n" if $self->{verbose};


        my $local_repo_dir = $self->{bare} ? "$local_repo_name.git" : $local_repo_name;
        if( -e $local_repo_dir && !$self->{force} ) {
            print("Found $local_repo_dir, skipped.\n"),next if $self->{skip_exists};

            chdir $local_repo_dir;
            my $guard = guard { chdir ".." };    # switch back
            print "Updating $local_repo_dir from remotes ..." . $print_progress->() . "\n";

            if( qx{ git config --get core.bare } =~ /\Atrue\n?\Z/ ) {
                # "Automatic synchronization of 2 git repositories | Pragmatic Source"
                # http://www.pragmatic-source.com/en/opensource/tips/automatic-synchronization-2-git-repositories

                my ($branch) = map { s/\A\* (.+)/$1/; $_ } grep /\A\*/, split /\n/, qx{ git branch };
                my $remote = qx{ git config --get branch.$branch.remote };
                chomp $remote;
                if ($remote =~ /\A\s*\Z/) {
                    print STDERR "branch.$branch.remote is not set, skipped.";
                    next;
                }
                unless (grep /^$remote/, split /\n/, qx{ git remote }) {
                    print "$local_repo_dir: Need remote '$remote' for updating '$local_repo_dir', skipped.";
                    next;
                }
                qx{ git fetch $remote };
                qx{ git reset --soft refs/remotes/$remote/$branch };
            }
            else {
                my $flags = qq();
                $flags .= qq{ -q } unless $self->{verbose};
                qx{ git pull $flags --rebase --all };
            }
        }
        else {
            print "Cloning " . $repo->{name} . " ... " . $print_progress->() . "\n";

            if ($self->{force}) {
                rmtree $local_repo_dir or do {
                    print STDERR "could not remove '$local_repo_dir', skipped.";
                    next;
                };
            }

            my $flags = qq();
            $flags .= qq{ -q } unless $self->{verbose};
            $flags .= qq{ --bare } if $self->{bare};

            my $reponame =
                    $self->{prefix} 
                        ?  $self->{prefix} . "-" . $repo->{name} 
                        :  $repo->{name}  ;

            my $cmd = qq{ git clone $flags $uri $reponame};
            qx{ $cmd };

            if ($self->{bare}) {
                chdir $local_repo_dir;
                my $guard = guard { chdir ".." };    # switch back
                qx{ git remote add gh-bare $uri };
                qx{ git config branch.master.remote gh-bare };    # initial branch must be master.
            }
        }
    }




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
        prompt when cloning every repo.

    --into {path}
        clone repos into a {path}.

    --skip-exists, -s
        skip existed repos.

    --verbose
        verbose output.

    --bare
        clone repos as bare repos.

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
