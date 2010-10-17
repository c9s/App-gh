package App::gh::Command::Drop;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh::Utils;
use LWP::Simple qw(get);
use JSON;

=head1 NAME

App::gh::Command::Drop - drop a repository.

=head1 USAGE

    $ gh drop [repository]

=cut

sub run {
    my ($self,$repo) = @_;
    my $auth = get_github_auth();

    $repo =~ s{::}{-}g;

    unless( $auth ) {
        die "Github authtoken not found. Can not fork repository.\n";
    }
    die unless $repo;

    print "Deleting @{[ $auth->{user} ]}/@{[ $repo ]}\n";

    # repos/delete/:user/:repo
    my $uri = sprintf( qq{repos/delete/%s/%s?login=%s&token=%s}, $auth->{user}, $repo, $auth->{user}, $auth->{token} );
    my $ret = api_request($uri);
    my $delete_token = $ret->{delete_token};
    $uri .= '&delete_token=' . $delete_token;
    $ret = api_request($uri);
    print $ret->{status} , "\n";
    return;
}





1;
