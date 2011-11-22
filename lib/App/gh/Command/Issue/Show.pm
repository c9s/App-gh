package App::gh::Command::Issue::Show;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh::Utils;
use File::stat;
use File::Temp;
use Text::Wrap;
require App::gh::Git;


=head1 NAME

App::gh::Command::Issue::Show - show the issue.

=head1 DESCRIPTION

=head1 USAGE

=pod

    $ gh issue show [number]

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
    return App::gh::Command->invoke('help', 'issue', 'show')
        unless defined $number;

    my $remote = $self->get_remote();

    die "Remote not found\n." unless $remote;
    my ( $user, $repo, $uri_type ) = parse_uri( $remote->{url} );

    my $gh_id = App::gh->config->github_id;
    my $gh_token = App::gh->config->github_token;
    unless( $gh_id && $gh_token ) {
        die "Github authtoken not found. Can not get issue.\n";
    }

    my $data = App::gh->api->issue_get($user, $repo, $number);
    my $issue = $data->{issue};
    printf "Title: %s\n", $issue->{title};
    printf "Author: %s\n", $issue->{user};
    printf "\n%s\n\n", $issue->{body};

    $data = App::gh->api->issue_get_comments($user, $repo, $number);
    for my $d (@{$data->{comments}}) {
        print "-" x 78 . "\n";
        printf "%s:\n%s\n", $d->{user}, $d->{body};
    }
}

1;
