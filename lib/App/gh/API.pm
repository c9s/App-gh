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
    my ( $class, $query , %args ) = @_;
    my $ua = $class->new_ua;
    my $url = URI->new('http://github.com/api/v2/json/' . $query );
    my $github_id     =  App::gh->config->github_id();
    my $github_token  =  App::gh->config->github_token();

    my $response      =  $ua->post( $url, { login => $github_id, token => $github_token , %args } );

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


sub search {
    my ($class,$query) = @_;
    return $class->request(qq{repos/search/$query});
}

sub fork {
    my ( $class, $user, $repo) = @_;
	my $gh_id = App::gh->config->github_id;
	my $gh_token = App::gh->config->github_token;
    unless( $gh_id && $gh_token ) {
        die "Github authtoken not found. Can not fork repository.\n";
    }
    return $class->request( sprintf("repos/fork/%s/%s?login=%s&token=%s", $user , $repo , $gh_id , $gh_token ));
}

sub network {
    my ( $class, $user, $repo ) = @_;
    my $ret = $class->request(qq(repos/show/$user/$repo/network));
    return $ret->{network};
}


sub user_info {
    my ($class,$user) = @_;
    return $class->request( qq{repos/show/$user} );
}

sub user_repositories {
    my ($class,$user) = @_;
    my $ret = $class->user_info( $user );
    return $ret->{repositories};
}




1;
__END__
=head1 NAME

App::gh::API - Github API class

=head1 FUNCTIONS

=head2 fork ([Str] user, [Str] repo)

To fork [repo] from [user].

=head2 network( [Str] user, [Str] repo)

Show repository networks of [user]'s [repo].

=cut
