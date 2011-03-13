package App::gh::Command::Import;
use warnings;
use strict;
use base qw(App::gh::Command);
use File::Basename;
use Cwd;
require App::gh::Git;
use Carp;

sub options {
    'n|name=s'  => 'name',
    'd|description=s' => 'description',
    'homepage=s' => 'homepage',
    'p|private' => 'private',
    'r|remote=s' => 'remote',
}

sub run {
    my ($self) = @_;
    my $local_repo = Git->repository();
    my $remote = $self->{remote} || 'origin';
    my $config = App::gh->config->current();
    my $basename = basename( $local_repo->wc_path() );
    my $reponame = $self->{name} || $basename;
    my $gh_id = App::gh->config->github_id();

    # Check if remote already exists
    if ($local_repo->config("remote.$remote.fetch")) {
        croak "Remote [$remote] already exists. Try specifying another one using --remote.";
    }

    # Check if repo already exists
    my $existing_gh_repo = eval { App::gh->api->repo_info( $gh_id, $reponame ) };
    if ($existing_gh_repo) {
        # Update existing repo
        my %args = (
            description => ($self->{description}
                                || $existing_gh_repo->{description} || ""),
            homepage => ($self->{homepage}
                             || $existing_gh_repo->{homepage} || "" ),
            # Don't change visibility of existing repo
            # public => $self->{private} ? 0 : 1 ,
        );
        my $ret = App::gh->api->repo_set_info( $gh_id, $reponame, %args );
        print "Repository updated: \n";
        App::gh::Utils->print_repo_info( $ret );
    }
    else {
        # Create new repo
        my %args = (
            name => $reponame,
            description => ($self->{description} || ""),
            homepage => ($self->{homepage} || "" ),
            public => $self->{private} ? 0 : 1 ,
        );
        my $ret = App::gh->api->repo_create( %args );
        print "Repository created: \n";
        App::gh::Utils->print_repo_info( $ret );
    }

    print "Adding GitHub repo $reponame as remote [$remote].\n";
    $local_repo->command("remote", "add", "$remote",
                         "git\@github.com:${gh_id}/${reponame}.git");

    # Only set up branch remote if it isn't already set up.
    if (! $local_repo->config('branch.master.remote')) {
        print "Setting up remote [$remote] for master branch.\n";
        $local_repo->command('config', 'branch.master.remote', "$remote");
        $local_repo->command('config', 'branch.master.merge', 'refs/heads/master');
    }

    print "Pushing to remote [$remote]\n";
    $local_repo->command("push", "$remote", "master");

    print "Done.\n";
}

1;
__END__

=head1 NAME

App::gh::Command::Import - create and import a repository, or add a remote for an existing one.

=head1 OPTIONS

    --name, -n
            repository name.

    --description, -d
            description.

    --homepage
            homepage URL.

    --private
            to be a private repository.

    --remote, -r
            new remote name.

=head1 USAGE


    $ cd Foo
    $ git init
    # changes
    $ git add .
    $ git commit -a -m "First commit"
    $ gh import    # import to github


=head1 Github Import steps

  mkdir Test
  cd Test
  git init
  touch README
  git add README
  git commit -m 'first commit'
  git remote add origin git@github.com:c9s/Test.git
  git push origin master

Existing Git Repo?

  cd existing_git_repo
  git remote add origin git@github.com:c9s/Test.git
  git push origin master

=cut
