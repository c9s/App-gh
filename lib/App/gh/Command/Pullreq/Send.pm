package App::gh::Command::Pullreq::Send;
use base qw(App::gh::Command);
use v5.10;
use App::gh::Utils;
use File::stat;
use File::Temp;
require App::gh::Git;


=head1 NAME

App::gh::Command::PullReq::Send - pull request of current branch.

=head1 DESCRIPTION

=head1 USAGE

    $ gh pullreq send ([branch])

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

    unless ( $ENV{EDITOR} ) {
        say "\$EDITOR is not set. please set the EDITOR environment variable for editing.";
        say "\nUnix-like system users: \n";
        say "\tNano text editor, a simple text editor";
        say "\t\t export EDITOR=nano";
        say "\tVIM users please run:";
        say "\t\t export EDITOR=vim";
        say "\tEmacs users please run:";
        say "\t\t export EDITOR=emacs";

        say "\nWindows users please run:\n";
        say "\t\t set EDITOR=notepad.txt";
        say "";
        die;
    }

    my $remote_branch = shift||'master';
    my $remote = $self->get_remote();

    die "Remote not found\n." unless $remote;
    my ( $user, $repo, $uri_type ) = parse_uri( $remote->{url} );

    my $gh_id = App::gh->config->github_id;
    my $gh_token = App::gh->config->github_token;
    unless( $gh_id && $gh_token ) {
        die "Github authtoken not found. Can not send pull request.\n";
    }

    my $local_repo = Git->repository();
    open my $fh, '<', $local_repo->wc_path()."/.git/HEAD";
    my $ref = <$fh>;
    close $fh;
    chomp( $ref );

    my ($branch) = ( $ref =~ m{ref:\s\S+?/\S+?/(\S+)} );

    my $f = File::Temp->new(SUFFIX => ".mkd");
    my $t = stat($f->filename)->mtime;
    system $ENV{EDITOR}, $f->filename;
    if ($t == stat($f->filename)->mtime) {
        _info "No changes. Pull request was not sent.";
        return;
    }
    open $fh, '<', $f->filename;
    my $content = do { local $/; <$fh> };
    close $fh;
    my ($title, $body) = split("\n", $content, 2);
    chomp( $title );
    chomp( $body );

    if (length($title) == 0 || length($body) == 0) {
        _info "Message should two lines at least.";
        return;
    }

    _info "Sending pull request for $branch...";
    my $data = App::gh->api->pullreq_send($user, $repo, $branch, $remote_branch, $title, $body);

    _info "Sent: " . $data->{pull}->{html_url};
}


1;
