package App::gh::Command::Upload;
use warnings;
use strict;
use base qw(App::gh::Command);
use Net::GitHub::Upload;
use App::gh::Utils;

=head1 USAGE

    gh upload {file} [{repo}]

    gh upload App-gh.tar.gz

    gh upload App-gh.tar.gz c9s/App-gh

=cut

sub run {
    my ( $self, $file, $repo ) = @_;

    my $auth = get_github_auth();
    unless( $auth ) {
        die "Github authtoken not found.\n";
    }

    my $gh = Net::GitHub::Upload->new(
        login => $auth->{user},
        token => $auth->{token},
    );

    $repo ||= $auth->{user} . '/' . $self->get_current_repo();
    print "Uploading $file to $repo\n";

    $gh->upload(
        repos => $repo,
        file  => $file,
    );
    print "Done\n";
}



1;
