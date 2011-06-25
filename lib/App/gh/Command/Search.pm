package App::gh::Command::Search;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh::Utils;
use App::gh;

=head1 NAME

App::gh::Command::Search - search repositories

=head1 USAGE

    $ gh search perl6

=cut

sub run {
    my ($self,$keyword) = @_;
    my $result = App::gh->api->search($keyword);
    my @ary = ();
    for my $repo ( @{ $result->{repositories} } ) {
        my $name = sprintf "%s/%s", $repo->{username} , $repo->{name};
        my $desc = $repo->{description};
        push @ary, [ $name , $desc ];
    }
    print_list @ary;
}

1;
