package App::gh::Command::Issue::List;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh::Utils;
use Text::Wrap;
use File::stat;
use File::Temp;
require App::gh::Git;


=head1 NAME

App::gh::Command::Issue::List - show list of issues.

=head1 DESCRIPTION

=head1 USAGE

=pod

    $ gh issue list

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
    my $self = shift;

    my $remote = $self->get_remote();

    die "Remote not found\n." unless $remote;
    my ( $user, $repo, $uri_type ) = parse_uri( $remote->{url} );

    my $gh_id = App::gh->config->github_id;
    my $gh_token = App::gh->config->github_token;
    unless( $gh_id && $gh_token ) {
        die "Github authtoken not found. Can not get issues.\n";
    }

    my $data = App::gh->api->issue_list($user, $repo);
    unless (@{$data->{issues}}) {
        _info "No issues found.";
    } else {
        for my $issue (@{$data->{issues}}) {
            printf "* Issue %-4d [%s] %s - %s\n" , 
                    $issue->{number}, 
                    ucfirst($issue->{state}),
                    $issue->{title}, 
                    $issue->{user};
            printf "  Date       %s\n", $issue->{created_at};
            printf "  Url        %s\n", $issue->{html_url};
            # use Data::Dumper; warn Dumper( $issue->{body} );
            printf "\n%s",wrap " " x 6," " x 6,$issue->{body};
            printf "\n\n";
            # printf "%04d:%s: %s\n", $issue->{number}, $issue->{user}, $issue->{title};
        }
    }
}


1;
