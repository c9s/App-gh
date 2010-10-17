package App::gh::Command::Clone;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh::Utils;
use LWP::Simple qw(get);
use App::gh::Utils;
use JSON;

=head1 NAME

App::gh::Command::Clone - clone repository

=head1 DESCRIPTION

balh

=head1 OPTIONS

    --verbose
    --ssh
    --http
    --https
    --git|ro

=cut

sub options { (
    "verbose" => "verbose",
    "ssh" => "protocal_ssh",    # git@github.com:c9s/repo.git
    "http" => "protocal_http",  # http://github.com/c9s/repo.git
    "https" => "https",         # https://github.com/c9s/repo.git
    "git|ro"   => "git"         # git://github.com/c9s/repo.git
) }

sub run {
    my ($self) = shift;

    my $user;
    my $repo;

    $user = shift;
    if( $user =~ /\// ) {
        ( $user, $repo ) = split /\//, $user;
    }
    else {
        $repo = shift;
    }

    unless( $user && $repo ) {
        die "Usage [user] [repo]";
    }

    my $uri = $self->gen_uri( $user, $repo );
    print $uri . "\n";
    system( qq{git clone $uri} );
}

1;
