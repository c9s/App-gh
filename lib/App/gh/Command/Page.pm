package App::gh::Command::Page;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh;
use App::gh::Utils;

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

sub run {
    my $self = shift;
    my $repo = App::gh->git;
    $repo->command('symbolic-ref','HEAD','refs/heads/gh-pages');
    $repo->command('clean','-fdx');
    print "gh-pages created, please push gh-pages branch to github remote.\n";
}


1;
