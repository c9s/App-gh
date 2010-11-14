package App::gh::Command::All;
use utf8;
use warnings;
use strict;
use base qw(App::gh::Command);
use File::Path qw(mkpath);
use App::gh::Utils;
use LWP::Simple qw(get);
use JSON;

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
    ) }


sub run {
    my $self = shift;
    my $acc  = shift;

    $self->{into} ||= $acc;

    die 'Need account id.' unless $acc;

    _info "Getting repository list from github: $acc";

    my $repolist = App::gh->api->user_repos( $acc );
    return if @{ $repolist } == 0;

    if( $self->{into} ) {
        print STDERR "Cloning all repositories into @{[ $self->{into} ]}\n";
        mkpath [ $self->{into} ];
        chdir  $self->{into};
    }

    _info "Will clone repositories below:";
    print " " x 8 . join " " , map { $_->{name} } @{ $repolist };
    print "\n";

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
        if( -e $local_repo_dir ) {
            print("Found $local_repo_dir, skipped.\n"),next if $self->{skip_exists};
            print("$local_repo_dir: git-pull cannot be used for bare repository, skipped.\n"),next if $self->{bare};

            chdir $local_repo_dir;
            print "Updating $local_repo_dir from remotes ...\n";

            my $flags = qq();
            $flags .= qq{ -q } unless $self->{verbose};

            qx{ git pull $flags --rebase --all };

            # switch back
            chdir "../";
        }
        else {
            print "Cloning " . $repo->{name} . " ...\n";

            my $flags = qq();
            $flags .= qq{ -q } unless $self->{verbose};
            $flags .= qq{ --bare } if $self->{bare};

            qx{ git clone $flags $uri };
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

    --into          
        a path for repos.

    --skip-exists, -s
        skip existed repos.

    --verbose

Clone URL format:

    --ssh

    --http

    --https

    --git

=cut
