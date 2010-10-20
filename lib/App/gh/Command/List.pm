package App::gh::Command::List;
use warnings;
use strict;
use base qw(App::gh::Command);

use App::gh::Utils;
use LWP::Simple qw(get);
use JSON;


sub options {
    ( 'n|name' => 'name' )
}


sub run {
    my ( $self, $acc ) = @_;

    $acc =~ s{/$}{};

    my $json = get 'http://github.com/api/v2/json/repos/show/' . $acc;
    my $data = decode_json( $json );
    my @lines = ();
    for my $repo ( @{ $data->{repositories} } ) {
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

