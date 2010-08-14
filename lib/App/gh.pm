package App::gh;
use warnings;
use strict;
use Exporter::Lite;

our $VERSION = '0.114';

our @EXPORT = qw(parse_config parse_options get_github_auth);

sub parse_config {
    my ($file) = @_;
    open FH , "<" , $file;
    local $/;
    my $content = <FH>;
    close FH;
    my @parts = split /(?=\[.*?\])/,$content;


    my %config;

    for my $part ( @parts ) {
        if( $part =~ /^\[(\w+)\s+["'](\w+)["']\]/g ) {
            my ($o1 , $o2 ) = ($1, $2);
            $config{ $o1 } ||= {};
            $config{ $o1 }->{ $o2 } 
                = parse_options( $part );
        }
        elsif( $part =~ /^\[(.*?)\]/g  ) {
            my $key = $1;
            my $options = parse_options( $part );
            $config{ $key } = $options;
        }
    }
    return \%config;
}

sub parse_options {
    my $part = shift;
    my $options;
    while(  $part =~ /^\s*(.*?)\s*=\s*(.*?)\s*$/gm ) {
        my ($name,$value) = ($1,$2);
        $options->{ $name } = $value;
    }
    return $options;
}

sub get_github_auth {
    my $config = parse_config $ENV{HOME} . "/.gitconfig";
    return $config->{github};
}

__END__

=head1 NAME

App::gh - An apt-like Github utility.

=head1 DESCRIPTIONS

App-gh provides an interface for you clone, fork, search github repository very
easily. You can even clone all repositories from an author , for example:

    $ gh cloneall miyagawa

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


=head1 SYNOPSIS

list all repository of c9s:

    $ gh list c9s

if you want text wrapped:

    $ WRAP=1 gh list c9s

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

search repository:

    $ gh search Plack

to clone all repository of miyagawa:

    $ gh cloneall miyagawa 

    $ gh cloneall clkao ro  # read-only

to fork project:

    $ gh fork clkao AnyMQ

to fork current project:

    $ cd miyagawa/Tatsumaki
    $ gh fork

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
