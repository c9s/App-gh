package App::gh::Command::Search;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh::Utils;
use LWP::Simple qw(get);
use App::gh::Utils;
use JSON;


sub run {
    my ($self,$keyword) = @_;
    my $json = get 'http://github.com/api/v2/json/repos/search/' . $keyword;
    my $result = decode_json( $json );
    my @ary = ();
    for my $repo ( @{ $result->{repositories} } ) {
        my $name = sprintf "%s/%s", $repo->{username} , $repo->{name};
        my $desc = $repo->{description};
        push @ary, [ $name , $desc ];
    }
    print_list @ary;
}

1;
