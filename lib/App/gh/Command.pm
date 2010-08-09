package App::gh::Command;
use warnings;
use strict;
use App::gh::Utils;

sub require_global_gitconfig { 0 }

sub require_local_gitconfig { 0 }

sub require_github_auth { 0 }

sub new {
    my $class = shift;
    return bless {}, $class;
}

sub global_help {
    # XXX: scan command classes
    print <<'END';
App::gh

show help message;

    $ gh help

* list:

    list all repository of c9s:

        $ gh list c9s

    if you want text wrapped:

        $ WRAP=1 gh list c9s

* clone:

    clone Plack repository from miyagawa:

        $ gh clone miyagawa/Plack   # default: read-only 

    or:

        $ gh clone miyagawa Plack

        $ gh clone gugod Social http

        $ gh clone clkao Web-Hippie ro

    clone from read-only uri:

        $ gh clone miyagawa/Plack ro 

    clone from ssh uri:

        $ gh clone miyagawa/Plack ssh  

* search:

    search repository:

        $ gh search Plack

* cloneall:

    to clone all repository of miyagawa:

        $ gh cloneall miyagawa 

        $ gh cloneall clkao ro  # read-only

* fork;

    to fork project:

        $ gh fork clkao AnyMQ

    to fork current project:
        
        $ cd clkao/AnyMQ
        $ gh fork

* network:

    to show fork network:

        $ cd App-gh/
        $ gh network
            c9s/App-gh - watchers(4) forks(1)
          gugod/App-gh - watchers(1) forks(0)

* pull from other's fork:

    pull from gugod/project.git branch master (default):

        $ cd project
        $ gh pull gugod           

    pull from gugod/project.git branch feature:

        $ cd project
        $ gh pull gugod feature    

END
}

sub help {
    my ($self,$cmd,@args) = @_;
    print "$cmd command doesnt have help message.\n";
}

sub get_cmd_class {
    my $cmd = shift;
    return __PACKAGE__ . "::" . ucfirst( $cmd );
}

sub new_xd {
    my $cmd = shift;
    my $cmd_class = get_cmd_class($cmd);

    eval "use $cmd_class;";
    if( $@ ) {
        die "No such gh command.\n";
    }
    my $xd = $cmd_class->new();
    return $xd;
}

sub dispatch {
    my ( $class, $cmd, @args ) = @_;
    if( $cmd eq 'help' ) {
        my $subcmd = shift @args;
        my $xd;
        if( $subcmd ) {
            $xd = new_xd( $subcmd );
            $xd->help( $subcmd , @args );
        }
        else {
            global_help();
        }
        return 0;
    }

    my $xd = new_xd( $cmd );
    # eval "require $cmd_class.pm;";
    if( $xd->require_local_gitconfig ) {
        die "Git config not found." if ( ! -e ".git/config" );
    }
    if( $xd->require_github_auth ) {
        # XXX:
    }
    $xd->run( @args );
}


1;
