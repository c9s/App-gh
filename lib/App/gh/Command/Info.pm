package App::gh::Command::Info;
use utf8;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh;
use App::gh::Utils;

sub parse_uri {
    my ($uri) = @_;

    return ($2,$3,$1)
        if $uri =~ m{(git|https?)://github.com/(.*?)/(.*?).git};

    return ($1,$2,'git')
        if $uri =~ m{git\@github.com:(.*?)/(.*?).git};

     return ( $1, $2 )
        if $uri =~ m#([^/:]+)/([^/]+)(?:\.git)?$#;

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

    my $remote = $self->get_remote
        or die "Remote not found\n.";

    my ( $user, $repo ) = parse_uri( $remote->{url} );

    my $ret = App::gh->github->repos->get( $user, $repo );
    App::gh::Utils->print_repo_info( $ret );
}


1;
__END__

=encoding utf8

=head1 NAME

App::gh::Command::Info - show repository info

=head1 USAGE

    $ cd App
    $ gh info

=cut
