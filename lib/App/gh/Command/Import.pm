package App::gh::Command::Import;
use warnings;
use strict;
use base qw(App::gh::Command);
use File::Basename;
use Cwd;

=head1 Import steps

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

sub options {
    'n|name'  => 'name',
    'd|description' => 'description',
    'homepage' => 'homepage',
    'p|private' => 'private',
}

sub run {
    my ($self) = @_;
    my $config = App::gh->config->current();
    # use Data::Dumper; warn Dumper( $config );

    my $basename = basename( getcwd() );
    my %args = ( 
        name => ($self->{name} || $basename),
        description => ($self->{description} || ""),
        homepage => ($self->{homepage} || "" ),
        public => $self->{private} ? 0 : 1 ,
    );
    my $ret = App::gh->api->repo_create(  %args );
    use Data::Dumper; warn Dumper( $ret );
}


1;
__END__
=head1 NAME

App::gh::Command::Import - create and import a repository.

=cut
