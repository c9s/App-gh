package App::ghget;

use warnings;
use strict;

=head1 NAME

App::ghget - An apt-like Github clone utility.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    $ ghget list c9s

    $ ghget clone miyagawa/Plack

    $ ghget clone miyagawa/Plack ssh

    $ ghget search Plack

    $ ghget cloneall miyagawa 

    $ ghget cloneall miyagawa ro

=head1 AUTHOR

Cornelius, C<< <cornelius.howl at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-app-ghget at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=App-ghget>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc App::ghget


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=App-ghget>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/App-ghget>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/App-ghget>

=item * Search CPAN

L<http://search.cpan.org/dist/App-ghget/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2010 Cornelius.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of App::ghget
