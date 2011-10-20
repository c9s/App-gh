package App::gh::Command::Pullreq::Show;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh::Utils;
use File::stat;
use File::Temp;
require App::gh::Git;


=head1 NAME

App::gh::Command::PullReq::Show - show the pull request.

=head1 DESCRIPTION

=head1 USAGE

=pod

    $ gh pullreq show [number]

=cut

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

    my $data = App::gh->api->pullreq_get($user, $repo, $number);
    my $pull = $data->{pull};
    printf "title: %s\n", $pull->{title};
    printf "author: %s\n", $pull->{user}->{name};
    printf "request: %s => %s\n", $pull->{base}->{label}, $pull->{head}->{label};
    printf "\n%s\n\n", $pull->{body};
    for my $d (@{$pull->{discussion}}) {
        print "-" x 78 . "\n";
        if ($d->{type} eq 'IssueComment') {
            printf "%s:\n%s\n", $d->{user}->{name}, $d->{body};
        }
        if ($d->{type} eq 'Commit') {
            printf "%s:\n%s\n", $d->{author}->{name}, $d->{message};
        }
        if ($d->{type} eq 'PullRequestReviewComment') {
            printf "%s:\n%s\n", $d->{author}->{name}, $d->{body};
        }
    }
    print "-" x 78 . "\n";
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


1;
