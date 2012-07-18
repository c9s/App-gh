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

    $ gh pullreq send ([base branch]) ([owner]/[repo])

Base branch: the branch you fork from.

Owner/Repo:  the repository you fork from.

Example:

    $ gh pullreq send

    $ gh pullreq send master c9s/App-gh

=head1 API

API Spec is from L<http://develop.github.com/p/pulls.html>

    pull[base] - A String of the branch or commit SHA that you want your
        changes to be pulled to.

    pull[head] - A String of the branch or commit SHA of your changes.
        Typically this will be a branch. If the branch is in a fork of the original
        repository, specify the username first: "my-user:some-branch".

    pull[title] - The String title of the Pull Request (and the related Issue).

    pull[body] - The String body of the Pull Request.

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

    my $remote_branch = shift ||'master';
    my $base          = shift;
    my ($user,$repo,$uri_type);
    if( $base ) {
        ($user,$repo) = split m{[/:]},$base;

    } else {
        my $remote = $self->get_remote();
        die "Remote not found\n." unless $remote;
        ($user, $repo, $uri_type ) = parse_uri( $remote->{url} );
    }



    my $gh_id = App::gh->config->github_id;
    my $gh_token = App::gh->config->github_token;
    unless( $gh_id && $gh_token ) {
        die "Github authtoken not found. Can not send pull request.\n";
    }


    my $local_repo = App::gh->git;
    open my $fh, '<', $local_repo->wc_path()."/.git/HEAD";
    my $ref = <$fh>;
    close $fh;
    chomp( $ref );

    my ($branch) = ( $ref =~ m{ref:\s\S+?/\S+?/(\S+)} );

    my $f = File::Temp->new(SUFFIX => ".md");
    my $t = stat($f->filename)->mtime;

    open $fh , ">" , $f->filename;
    print $fh "Title\n";
    print $fh "Body (markdown format)\n";
    close $fh;

    # launch editor
    system $ENV{EDITOR}, $f->filename;

    if ($t == stat($f->filename)->mtime) {
        info "No changes. Pull request was not sent.";
        return;
    }

    open $fh, '<', $f->filename;
    my $content = do { local $/; <$fh> };
    close $fh;
    my ($title, $body) = split("\n", $content, 2);
    chomp( $title );
    chomp( $body );

    if (length($title) == 0 || length($body) == 0) {
        info "Message should two lines at least.";
        return;
    }

    info "Sending pull request for $branch...";
    # XXX: make arguments into hash format
    my $data = App::gh->api->pullreq_send($user, $repo, $branch, $remote_branch, $title, $body);

    info "Sent: " . $data->{pull}->{html_url};
}

1;
