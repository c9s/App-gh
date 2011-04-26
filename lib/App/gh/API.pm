package App::gh::API;
use warnings;
use strict;
use LWP::UserAgent;
use JSON::XS;
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

    # passing empty login/token triggers 401 unauthorized
    if ($github_id and $github_token) {
        @args{'login', 'token'} = ($github_id, $github_token);
    }
    my $response = $ua->post($url, %args);

    if ( ! $response->is_success ) {
        die $response->status_line . ': ' . $response->decoded_content;
    }

    my $json = $response->decoded_content;  # or whatever
    my $data;
    eval {
        $data = decode_json( $json );
    };

    die "JSON Error:" . $!  if $@ ;
    die $data->{error} if $data->{error};
    die "Empty response" unless( $data );
    return $data;
}

sub search {
    my ( $class, $query, %args ) = @_;
    return $class->request( qq{repos/search/$query}, %args );
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

sub repo_network {
    my ( $class, $user, $repo ) = @_;
    my $ret = $class->request(qq(repos/show/$user/$repo/network));
    return $ret->{network};
}

sub repo_info {
    my ( $class, $user, $repo ) = @_;
    my $ret = $class->request(qq{repos/show/$user/$repo});
    return $ret->{repository} if $ret;
}

sub repo_create {
    my ($class,%args) = @_;
    my $ret = $class->request( qq{repos/create} , %args );
    return $ret->{repository} if $ret;
}

sub user_info {
    my ($class,$user,$page) = @_;
    $page ||= 1;
    my $ret =  $class->request( qq{repos/show/$user?page=$page} );
    return $ret if $ret;
}

sub user_repos {
    my ($class,$user) = @_;
    my @repos;
    my $page;
    while (1) {
        my $ret = $class->user_info( $user, $page++ );
        last unless @{$ret->{repositories}};
        push @repos, @{$ret->{repositories}};
    }
    return \@repos;
}

# Added by RCT
sub repo_set_public {
    my ( $class, $user, $repo, $public ) = @_;
    my $visibility = $public ? "public" : "private";
    my $ret = $class->request( qq{repos/set/$visibility/$user/$repo} );
    return $ret;
}

sub repo_set_info {
    my ( $class, $user, $repo, %args ) = @_;
    if (exists $args{public}) {
        $class->repo_set_public( $user, $repo, $args{public} );
        delete $args{public};
    }
    # Keys must be in the form 'values[key]'
    %args = map { ("values[$_]" => $args{$_}) } (keys %args);
    my $ret = $class->request( qq{repos/show/$user/$repo} , %args );
    return $ret->{repository};
}

1;
__END__

=head1 NAME

App::gh::API - Github API class

=head1 FUNCTIONS

=head2 search( [Str] query )

Search repositories

=head2 fork ([Str] user, [Str] repo)

To fork [repo] from [user].

=head2 repo_network( [Str] user, [Str] repo)

Show repository networks of [user]'s [repo].

=head2 user_info( [Str] user )

Show user info

=head2 repo_create( [Hash] args )

args:

    name =>
    description =>
    homepage =>
    public => 1 for public , 0 for private.

=head2 repo_info( [Str] user, [Str] repo)

Which returnes a hashref:

    {
        'owner' => 'c9s',
        'has_downloads' => bless( do{\(my $o = 1)}, 'JSON::XS::Boolean' ),
        'has_issues' => $VAR1->{'repository'}{'has_downloads'},
        'name' => 'App-gh',
        'private' => bless( do{\(my $o = 0)}, 'JSON::XS::Boolean' ),
        'has_wiki' => $VAR1->{'repository'}{'has_downloads'},
        'pushed_at' => '2010/11/13 09:15:44 -0800',
        'description' => 'Powerful GitHub Helper Utility in Perl.',
        'forks' => 6,
        'watchers' => 23,
        'fork' => $VAR1->{'repository'}{'private'},
        'created_at' => '2010/07/20 22:58:00 -0700',
        'url' => 'https://github.com/c9s/App-gh',
        'open_issues' => 4
    }

=head2 repo_set_info ( [Str] user, [Str] repo, [Hash] args )

Set the info of a repo. Hash can contain the following args:

    description =>
    homepage =>
    public => 1 for public , 0 for private.

These are the same args as repo_create, except for name.

=head2 repo_set_public ( [Str] user, [Str] repo, [Bool] public )

Set a repo to be public or private.

=cut
