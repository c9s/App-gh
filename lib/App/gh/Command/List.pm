package App::gh::Command::List;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh;

use App::gh::Utils;
use LWP::Simple qw(get);
use JSON;


=head1 NAME

App::gh::Command::List - list repository from one.

=head1 USAGE

    $ gh list [user id]

=cut

sub options {
    ( 'n|name' => 'name' )
}

sub run {
    my ( $self, $acc ) = @_;

    $acc =~ s{/$}{};

	# TODO: use api class.
	my $repolist = App::gh->api->user_repos( $acc );
    my @lines = ();
    for my $repo ( @$repolist ) {
        my $repo_name = $repo->{name};

        if( $self->{name} ) {
            print $acc . "/" . $repo->{name} , "\n";
        }
        else {
            push @lines , [  
                $acc . "/" . $repo->{name} ,
                ($repo->{description}||"")
            ];
        }

    }
    print_list @lines if @lines;
}

1;

