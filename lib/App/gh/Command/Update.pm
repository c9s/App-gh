package App::gh::Command::Update;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh::Utils;


=head1 NAME

=head1 DESCRIPTION

simply run git pull --all , and push

=cut

sub run {
    my $self = shift;
    my @lines = split /\n/,qx{ git remote -v | grep '(fetch)'};

    _info "Running update --prune";
    qx{ git remote update --prune  };

    for my $line ( @lines ) {
        my ( $remote , $uri , $type ) = ($line =~ m{^(\w+)\s+(\S+)\s+\((\w+)\)} );
        # use Data::Dumper; warn Dumper( $remote , $uri , $type );
        _info "Updating from $remote ...";
        qx{ git pull $remote };

        if( $uri =~ /^git\@github\.com/ ) {
            _info "Pushing changes to $remote : $uri";
            qx{ git push  $remote };
        }
    }


}

1;
