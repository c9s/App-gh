package App::gh::Command::Pullreq::List;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh::Utils;
use File::stat;
use File::Temp;
use Text::Wrap;
require App::gh::Git;


=head1 NAME

App::gh::Command::PullReq::List - show list of pull requests.

=head1 DESCRIPTION

=head1 USAGE

    $ gh pullreq list

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
        die "Github authtoken not found. Can not get pull requests.\n";
    }


    my $data = App::gh->api->pullreq_list( $user, $repo );
    unless (@{$data->{pulls}}) {
        _info "No pull request found.";
    } else {
        eval { require IO::Pager; };
        unless ($@) {
            local $STDOUT = new IO::Pager *STDOUT;
        }
        for my $pull (@{$data->{pulls}}) {
            printf "* Issue %d: %s - %s (%s)\n", $pull->{number} , 
                $pull->{title},
                $pull->{user}->{name}, 
                $pull->{user}->{login};
            printf "  Diff: %s\n", $pull->{diff_url};
            print "\n";
            print  "  " . wrap( "", "\t", $pull->{body} );
            print "\n";
        }
    }
}

1;
