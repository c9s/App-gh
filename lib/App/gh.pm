package App::gh;
use warnings;
use strict;
our $VERSION = '0.272';
use App::gh::Config;
use App::gh::API;

sub config {
    return "App::gh::Config";
}

sub api {
    return "App::gh::API";
}

__END__

=head1 NAME

App::gh - An apt-like Github utility.

=head1 DESCRIPTIONS

App-gh provides an interface for you clone, fork, search github repository very
easily. You can even clone all repositories from an author , for example:

    $ gh all miyagawa
    $ gh all miyagawa --into path/

this will clone all repositories of miyagawa.

Or you can search repository:

    $ gh search AnyEvent

Or list all repository of an author:

    $ gh list c9s

You may clone a repository from an author, then you might want to fork the repository:

    $ gh clone gugod Social
    $ cd Social
    $ gh fork

This will fork gugod/Social into yourID/Social. and will add a remote name
called 'c9s' (your fork).

And you might want to show all forks of this repository:

    $ gh network

to pull changes from one fork.

    $ gh pull gugod [branch]

This will pull changes from gugod/[branch].  specify --merge to merge these
changes. --branch if you want the forked branch to be checked out.

=head1 SYNOPSIS

list all repository of c9s:

    $ gh list c9s

clone Plack repository from miyagawa:

    $ gh clone miyagawa/Plack   # default: read-only 

or:

    $ gh clone miyagawa Plack

    $ gh clone gugod Social --http

    $ gh clone clkao Web-Hippie --ro

clone from read-only uri:

    $ gh clone miyagawa/Plack --ro 

clone from ssh uri:

    $ gh clone miyagawa/Plack --ssh  

search repository:

    $ gh search Plack

to clone all repository of miyagawa:

    $ gh all miyagawa 
    $ gh all clkao --ro  # read-only
    $ gh all clkao --into path/to/clkao

to fork project:

    $ cd AnyMQ
    $ gh fork clkao

to fork current project:

    $ cd miyagawa/Tatsumaki
    $ gh fork

=head1 ALIASES

    a  => all
    u  => update
    pu => pull
    f  => fork
    n  => network
    s  => search

=head1 AUTHOR

Cornelius, C<< <cornelius.howl at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-app-gh at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-gh>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::gh

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=App-gh>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App-gh>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/App-gh>

=item * Search CPAN

L<http://search.cpan.org/dist/App-gh/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2010 Cornelius.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of App::gh
