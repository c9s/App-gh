package App::gh::Command::Push;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh::Utils;


=head1 NAME

App::gh::Command::Push - push changes to writable github remotes

=cut

sub run {
    my $self = shift;

    die unless( -e ".git/HEAD" );

    open FH , "<" , ".git/HEAD";
    my $ref = <FH>;
    close FH;
    chomp( $ref );

    my ($branch) = ( $ref =~ m{ref:\s(\S+)} );

    my @lines = split /\n/,qx{ git remote -v | grep '(fetch)'};
    for my $line ( @lines ) {
        my ( $remote , $uri , $type ) = ($line =~ m{^(\w+)\s+(\S+)\s+\((\w+)\)} );
        _info "Updating from $remote ...";
        qx{ git pull --rebase $remote $branch};

        if( $uri =~ /^git\@github\.com/ ) {
            _info "Pushing changes to $remote : $uri";
            qx{ git push $remote $branch};
        }
    }
}

1;
