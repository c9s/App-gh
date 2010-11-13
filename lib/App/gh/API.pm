package App::gh::API;
use warnings;
use strict;
use LWP::UserAgent;
use JSON::XS;
# XXX: move to othere place
use App::gh::Utils;

sub new_ua {
    my $class = shift;
    my $ua = LWP::UserAgent->new;  # TODO: make this switchable.  better client ? Furl ?
    $ua->timeout(10);
    $ua->env_proxy;
    return $ua;
}

sub request {
    my ( $class, $rest ) = @_;
    my $ua = $class->new_ua;
    my $url = URI->new('http://github.com/api/v2/json/' . $rest);
    my $github_id     =  App::gh->config->github_id();
    my $github_token  =  App::gh->config->github_token();
    my $response      =  $ua->post( $url, { login => $github_id, token => $github_token } );

    if ( ! $response->is_success) {
        die $response->status_line . ': ' . $response->decoded_content;
    }
    my $json = $response->decoded_content;  # or whatever
    my $data;
    eval {
        $data = decode_json( $json );
    };
    if( $@ ) {
        die "JSON Error:" . $!;
    }

    if( $data->{error} ) {
        die $data->{error};
    }

    unless( $data ) {
        die "Empty response";
    }
    return $data;
}


sub network {
    my $class = shift;
    my $config = $class->config->current();
    my ( $name , $url ) = split( /\s+/ , qx( git remote -v | grep origin | grep push ) );

    # git://github.com/miyagawa/Tatsumaki.git
    if ( $url && ( $url =~ m{git://github.com/(.*?)/(.*?).git} 
            || $url =~ m{git\@github.com:(.*?)/(.*?).git} ) ) {

        my ($acc,$repo) = ($1,$2);
        my $objs = api_request(qq(repos/show/$acc/$repo/network));
        return $objs->{network};
    }
}



1;
__END__
=head1 NAME

App::gh::API - Github API class

=cut
