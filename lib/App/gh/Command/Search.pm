package App::gh::Command::Search;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh::Utils;
use JSON;


=head1 NAME

App::gh::Command::Search - search repositories

=cut

sub run {
    my ($self,$keyword) = @_;
    my $result = api_request(qq(repos/search/$keyword));
    my @ary = ();
    for my $repo ( @{ $result->{repositories} } ) {
        my $name = sprintf "%s/%s", $repo->{username} , $repo->{name};
        my $desc = $repo->{description};
        push @ary, [ $name , $desc ];
    }
    print_list @ary;
}

1;
