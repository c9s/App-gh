package App::gh::Command::Info;
use utf8;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh;
use App::gh::Utils;

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
    # my $gh_id = App::gh->config->github_id();
    my $remote = $self->get_remote();
    die "Remote not found\n." unless $remote;
    my ( $user, $repo, $uri_type ) = parse_uri( $remote->{url} );
    my $ret = App::gh->api->repo_info( $user, $repo );
    App::gh::Utils->print_repo_info( $ret );
}


1;
__END__

=head1 NAME

App::gh::Command::Info - show repository info

=head1 USAGE

    $ cd App
    $ gh info

=cut
