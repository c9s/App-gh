package App::gh::Command::Fork;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh::Utils;
use LWP::Simple qw(get);
use JSON;



# curl -F 'login=schacon' -F 'token=XXX' http://github.com/api/v2/yaml/repos/fork/dim/retrospectiva

=pod

$VAR1 = {
          'repository' => {
                            'has_downloads' => bless( do{\(my $o = 1)}, 'JSON::XS::Boolean' ),
                            'owner' => 'c9s',
                            'has_issues' => bless( do{\(my $o = 0)}, 'JSON::XS::Boolean' ),
                            'name' => 'AnyMQ',
                            'private' => $VAR1->{'repository'}{'has_issues'},
                            'has_wiki' => $VAR1->{'repository'}{'has_downloads'},
                            'pushed_at' => '2010/04/06 00:40:45 -0700',
                            'description' => 'Simple message queue based on AnyEvent',
                            'watchers' => 1,
                            'forks' => 0,
                            'homepage' => '',
                            'created_at' => '2010/07/21 06:08:11 -0700',
                            'fork' => $VAR1->{'repository'}{'has_downloads'},
                            'url' => 'http://github.com/c9s/AnyMQ',
                            'open_issues' => 0
                          }
        };
=cut


sub _parse_github_links {
  my $link=shift;
  
}

sub run {
    my $self=shift;
    my $user;
    my $repo;

    if (@_) {
        $user = shift;
    
       #copied from Github::Fork::Parent
       if ($user && $user=~m#^(?:\Qgit://github.com/\E|git\@github\.com:\E|\Qhttp://github.com/\E)([^/]+)/([^/]+)(?:\.git)?$#) {
            ($user,$repo)=($1,$2);
        } elsif( $user && $user =~ /\// ) {
            ($user,$repo) = split /\//,$user;
        }
        else {
            $repo = shift;
        }
    }


    my $auth = get_github_auth();

    unless( $auth ) {
        die "Github authtoken not found. Can not fork repository.\n";
    }


    unless ( $repo ) {
        # detect .git directory
        if ( -e ".git/config" ) {
            my $config = parse_config( ".git/config" );
            for my $remote ( values %{ $config->{remote} } ) {
                # git://github.com/miyagawa/Tatsumaki.git
                # http://github.com/miyagawa/Tatsumaki.git
                if ( $remote->{url} =~ m{(?:git|https?)://github.com/(.*?)/(.*?).git} 
                    || $remote->{url} =~ m{git\@github.com:(.*?)/(.*?).git} ) 
                {
                    die unless( $1 || $2 );

                    ($user,$repo) = ( $1 , $2 );

                    _info "Found GitHub repository of $user/$repo";

                    my $_remotes = qx(git remote | grep @{[ $auth->{user} ]});
                    if( $_remotes ) {
                        die "Remote @{[ $auth->{user} ]} exists.\n";
                    }

                    my $remote_uri = qq( git\@github.com:@{[ $auth->{user} ]}/$repo.git);
                    _info "Adding remote '@{[ $auth->{user} ]}' => $remote_uri";

                    # url = git@github.com:c9s/App-gh.git
                    my $cmd = qq( git remote add @{[ $auth->{user} ]} $remote_uri);
                    _debug $cmd;
                    qx($cmd);

                    _info "Remote added.";
                }
            }
        }
    }

    _info "Forking...";
    my $data = api_request( sprintf("repos/fork/%s/%s?login=%s&token=%s", $user , $repo , $auth->{user} , $auth->{token} ));

    use Data::Dumper; 
    _debug Dumper( $data );

    _info "Repository forked:";

    $data = $data->{repository};
    print "  Name:          " . $data->{name} . "\n";
    print "  Description:   " . $data->{description} . "\n";
    print "  Owner:         " . $data->{owner} . "\n";
    print "  Watchers:      " . $data->{watchers} . "\n";
    print "  Created at:    " . $data->{created_at} . "\n";
    print "  Pushed at:     " . $data->{pushed_at} . "\n";
    print "  Fork:          " . $data->{'fork'} . "\n";
    print "  URL:           " . $data->{url} . "\n";
    print "  Homepage:      " . ($data->{homepage}||'') . "\n";

}


1;
