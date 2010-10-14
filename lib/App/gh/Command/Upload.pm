package App::gh::Command::Upload;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh::Utils;

=head1 USAGE

    gh upload {file} [{repo}]

=cut

sub run {
    my ($self,$file,$repo) = @_;

    $repo ||= $self->get_current_repo();

    my $auth = get_github_auth();
    unless( $auth ) {
        die "Github authtoken not found.\n";
    }

    print "Uploading $file to $repo\n";
    my $gh = Net::GitHub::Upload->new(
        login => $auth->{user},
        token => $auth->{token},
    );

    $gh->upload(
        repos => $repo,
        file  => $file,
    );
    print "Done\n";
}



1;
