package App::gh::Command::Pullreq::Show;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh::Utils;
use File::stat;
use File::Temp;
use Text::Wrap;
use IO::Pager;
require App::gh::Git;


=head1 NAME

App::gh::Command::PullReq::Show - show the pull request.

=head1 DESCRIPTION

=head1 USAGE

=pod

    $ gh pullreq show [number]

        --diff     also print diff

=cut

sub options {
    "diff"       => "with_diff",
}

sub parse_uri {
    my ($uri) = @_;
    if ( $uri =~ m{(git|https?)://github.com/(.*?)/(.*?).git} ) {
        return ($2,$3,$1);
    } elsif ( $uri =~ m{git\@github.com:(.*?)/(.*?).git} ) {
        return ($1,$2,'git');
    }
    return undef;
}

sub get_remote {
    my $self = shift;
    my $config = App::gh->config->current();
    my %remotes = %{ $config->{remote} };
    # try to get origin remote
    return $remotes{origin} || (values( %remotes ))[0];
}

sub run {
    my ($self, $number) = @_;
    return App::gh::Command->invoke('help', 'pullreq', 'show')
        unless defined $number;

    my $remote = $self->get_remote();

    die "Remote not found\n." unless $remote;
    my ( $user, $repo, $uri_type ) = parse_uri( $remote->{url} );

    my $gh_id = App::gh->config->github_id;
    my $gh_token = App::gh->config->github_token;
    unless( $gh_id && $gh_token ) {
        die "Github authtoken not found. Can not get pull request.\n";
    }


    local $STDOUT = IO::Pager->new( *STDOUT );
    my $data = App::gh->api->pullreq_get($user, $repo, $number);
    my $pull = $data->{pull};
    printf "Title:    [%s] %s\n", ucfirst($pull->{state}) , $pull->{title};
    printf "Date:     %s\n", $pull->{created_at};
    printf "Author:   %s (%s)\n", $pull->{user}->{name}, $pull->{user}->{login};
    printf "Request:  %s => %s\n", $pull->{base}->{label}, $pull->{head}->{label};

    print  wrap "\t","\t",$pull->{body};
    print  "\n\n";

    my @discussions = @{ $pull->{discussion} };
    my @commits     = grep { $_->{type} eq 'Commit' } @discussions;

    print scalar(@commits) , " Commits:\n\n";
    for my $c ( @commits ) {
        printf "* Commit: %s\n",$c->{tree};
        printf "  Author: %s (%s) <%s>\n", $c->{author}->{name} , $c->{author}->{login} , $c->{author}->{email};
        printf "  Date:   %s\n" , $c->{committed_date};
        printf "\n%s\n\n",wrap "\t","\t", $c->{message};
    }

    for my $d ( @discussions ) {
        if ($d->{type} eq 'IssueComment') {
            printf "%s:\n%s\n", $d->{user}->{name}, $d->{body};
        }
        if ($d->{type} eq 'PullRequestReviewComment') {
            printf "%s:\n%s\n", $d->{author}->{name}, $d->{body};
        }
    }


    # XXX: need to patch App::CLI for subcommand help message
    # eg,
    #
    #    gh help pullreq show  # this doesn't work
    #
    if( 1 || $self->{with_diff} ) {
        print "=" x 78 . "\n";
        my $ua = LWP::UserAgent->new;
        $ua->timeout(10);
        $ua->env_proxy;
        my $res = $ua->get($pull->{patch_url});
        if ($res->is_success) {
            print $res->decoded_content;
        } else {
            warn $res->message;
        }
    }
}


1;
