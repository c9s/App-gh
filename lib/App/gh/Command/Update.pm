package App::gh::Command::Update;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh;
use App::gh::Utils;

# XXX: improve me

=head1 NAME

App::gh::Command::Update - remote update --prune

=head1 DESCRIPTION

Simply run git remote update --prune , git pull --all , then push back to
writable remotes.

=cut

sub run {
    my $self = shift;

    unless ( -d ".git" ) {
        die "Not a repository";
    }

    info "Running update --prune";
    qx{ git remote update --prune  };

    my @lines = split /\n/,qx{ git remote -v | grep '(fetch)'};
    for my $line ( @lines ) {
        my ( $remote , $uri , $type ) = ($line =~ m{^(\w+)\s+(\S+)\s+\((\w+)\)} );
        # use Data::Dumper; warn Dumper( $remote , $uri , $type );
        info "Updating from $remote ...";
        qx{ git pull --rebase $remote };

        if( $uri =~ /^git\@github\.com/ ) {
            info "Pushing changes to $remote : $uri";
            qx{ git push  $remote };
        }
    }

    info "Done";
}

1;
