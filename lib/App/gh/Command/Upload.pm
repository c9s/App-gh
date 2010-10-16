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

    gh upload App-gh.tar.gz --cpan   # also upload to cpan


=cut


sub options { ( 'c|cpan' => 'cpanupload') }

sub run {
    my ( $self, $file, $repo ) = @_;

    my $auth = get_github_auth();
    unless( $auth ) {
        die "Github authtoken not found.\n";
    }

    if( $self->{cpanupload} ) {
        print "Uploading file to CPAN.\n";
        $self->cpanupload( $file );
    }

    my $gh = Net::GitHub::Upload->new(
        login => $auth->{user},
        token => $auth->{token},
    );

    $repo ||= $auth->{user} . '/' . $self->get_current_repo();
    print "Uploading $file to Github: $repo\n";
    eval {
        $gh->upload(
            repos => $repo,
            file  => $file,
        );
    };
    print $@ . ':' . $! if $@;
    print "Done\n";
}


sub cpanupload {
    my ( $self, $file ) = @_;
    eval {
        use CPAN::Uploader;
    };

    if( $@ ) {
        warn 'Can not use CPAN::Uploader, please install it.';
        return;
    }

    my $from_file = CPAN::Uploader->read_config_file;

    my %arg;
    $arg{user} = uc $from_file->{user};
    if ( ! $arg{password}
        and defined $from_file->{user}
        and ($arg{user} eq uc $from_file->{user})
        ) {
        $arg{password} = $from_file->{password};
    }

    if (! $arg{password}) {
        require Term::ReadKey;
        local $| = 1;
        print "PAUSE Password: ";
        Term::ReadKey::ReadMode('noecho');
        chop($arg{password} = <STDIN>);
        Term::ReadKey::ReadMode('restore');
        print "\n";
    }

    CPAN::Uploader->upload_file(
        $file,
        \%arg,
    );

}



1;
