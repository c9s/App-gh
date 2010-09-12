package App::gh::Command;
use warnings;
use strict;
use App::gh::Utils;
use base qw(App::CLI App::CLI::Command);

sub alias {
    (
        "all" => "cloneall"
    );
}

sub invoke {
    my ($pkg, $cmd, @args) = @_;
    local *ARGV = [$cmd, @args];
    my $ret = eval {
        $pkg->dispatch();
    };
    if( $@ ) {
        warn $@;
    }
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

1;
