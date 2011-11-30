package App::gh::Command::Page;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh;
use App::gh::Utils;
use File::Spec;

=head1 NAME

App::gh::Command::Page - create GitHub gh-page

=head1 DESCRIPTION

=head1 USAGE

=pod

command flow:

    $ git symbolic-ref HEAD refs/heads/gh-pages
    $ rm .git/index
    $ git clean -fdx
    $ git push origin github


=cut

sub get_remote {
    my $self = shift;
    my $config = App::gh->config->current();
    my %remotes = %{ $config->{remote} };
    # try to get origin remote
    return $remotes{origin} || (values( %remotes ))[0];
}

sub parse_uri {
    my ($uri) = @_;
    if ( $uri =~ m{(git|https?)://github.com/(.*?)/(.*?).git} ) {
        return ($2,$3,$1);
    } elsif ( $uri =~ m{git\@github.com:(.*?)/(.*?).git} ) {
        return ($1,$2,'git');
    }
    return undef;
}

sub run {
    my $self = shift;
    my $git = App::gh->git;
    $git->command('symbolic-ref','HEAD','refs/heads/gh-pages');
    unlink File::Spec->join( $git->wc_path , '.git' , 'index' );
    $git->command('clean','-fdx');

    print "Branch gh-pages created\n";
    print "Please add your index.html page and commit the file.\n";
    print "Then push gh-pages branch to github remote.\n";
    print "\n";
    print "\t\$ git push origin gh-pages\n";
    print "\n";

    my $remote = $self->get_remote;
    die "Remote not found\n." unless $remote;
    my ($user,$repo,$uri_type) = parse_uri( $remote->{url} );

    # http://c9s.github.com/App-gh/
    my $id = App::gh->config->github_id;
    my $url = sprintf 'http://%s.github.com/%s', $id, $repo;
    print "Your preview URL: $url\n";

    print "Reference: http://pages.github.com/\n";
}


1;
