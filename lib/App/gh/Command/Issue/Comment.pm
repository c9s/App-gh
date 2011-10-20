package App::gh::Command::Issue::Comment;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh::Utils;
use File::stat;
use File::Temp;
require App::gh::Git;


=head1 NAME

App::gh::Command::Issue::Edit - comment to the issue.

=head1 DESCRIPTION

=head1 USAGE

=pod

    $ gh issue comment [number]

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

    die "\$EDITOR is not set." unless $ENV{EDITOR};

    my $number = shift||'';
    my $remote = $self->get_remote();

    die "Remote not found\n." unless $remote;
    my ( $user, $repo, $uri_type ) = parse_uri( $remote->{url} );

    my $gh_id = App::gh->config->github_id;
    my $gh_token = App::gh->config->github_token;
    unless( $gh_id && $gh_token ) {
        die "Github authtoken not found. Can not edit issue.\n";
    }

    my $f = File::Temp->new(SUFFIX => ".mkd");
    my $t = stat($f->filename)->mtime;
    system $ENV{EDITOR}, $f->filename;
    if ($t == stat($f->filename)->mtime) {
        _info "No changes. Issue was not sent.";
        return;
    }

    open my $fh, '<', $f->filename;
    my $body = do { local $/; <$fh> };
    close $fh;

    if (length($body) == 0) {
        _info "Message should have lines at least.";
        return;
    }

    _info "Sending comment to issue #$number...";
    my $data = App::gh->api->issue_comment($user, $repo, $number, $body);

    _info "sent";
}


1;
