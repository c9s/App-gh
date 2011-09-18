package App::gh::Command::Drop;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh::Utils;

=head1 NAME

App::gh::Command::Drop - drop a repository.

=head1 USAGE

    $ gh drop [repository]

=cut

sub run {
    my ($self,$repo) = @_;
    return App::gh::Command->invoke('help', 'drop')
        unless defined $repo;

	my $gh_id = App::gh->config->github_id();
	my $gh_token = App::gh->config->github_token();

    $repo =~ s{::}{-}g;

    unless( $gh_id && $gh_token ) {
        die "Github authtoken not found. Can not delete repository.\n";
    }

    print "Deleting @{[ $gh_id ]}/@{[ $repo ]}\n";

    # repos/delete/:user/:repo
    my $uri = sprintf( qq{repos/delete/%s/%s?login=%s&token=%s}, $gh_id , $repo, $gh_id , $gh_token );
    my $ret = App::gh->api->request($uri);
    my $delete_token = $ret->{delete_token};
    $uri .= '&delete_token=' . $delete_token;
    $ret = App::gh->api->request($uri);
    print $ret->{status} , "\n";
    return;
}





1;
