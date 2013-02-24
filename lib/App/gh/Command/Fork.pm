package App::gh::Command::Fork;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh::Utils;


=head1 NAME

App::gh::Command::Fork - fork current repository.

=head1 DESCRIPTION

=head1 USAGE

=pod

curl -F 'login=schacon' -F 'token=XXX' http://github.com/api/v2/yaml/repos/fork/dim/retrospectiva

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

sub options { (
    "verbose" => "verbose",
    "ssh" => "protocol_ssh",    # git@github.com:c9s/repo.git
    "http" => "protocol_http",  # http://github.com/c9s/repo.git
    "https" => "protocol_https",         # https://github.com/c9s/repo.git
    "git|ro"   => "protocol_git"         # git://github.com/c9s/repo.git
) }


sub run {
    my $self=shift;
    my $user;
    my $repo;

    if (@_) {
        $user = shift;

        # copied from Github::Fork::Parent
        if ($user && $user=~m{^(?:\Qgit://github.com/\E|git\@github\.com:\E|\Qhttp://github.com/\E)([^/]+)/([^/]+)(?:\.git)?$}) {
            ($user,$repo)=($1,$2);
        } elsif( $user && $user =~ /\// ) {
            ($user,$repo) = split /\//,$user;
        }
        else {
            $repo = shift;
        }
    }


	my $gh_id = App::gh->config->github_id;
	my $gh_token = App::gh->config->github_token 
        || App::gh->config->github_password;
    unless( $gh_id && $gh_token ) {
        die "Github credentials not found. Cannot fork repository.\n";
    }


    unless ( $repo ) {
        # detect .git directory
        if ( -e ".git/config" ) {
            my $config = App::gh->config->current();
            for my $remote ( values %{ $config->{remote} } ) {
                # git://github.com/miyagawa/Tatsumaki.git
                # http://github.com/miyagawa/Tatsumaki.git
                if ( $remote->{url} =~ m{(?:git|https?)://github.com/(.*?)/(.*?)\.git}
                    || $remote->{url} =~ m{git\@github.com:(.*?)/(.*?)\.git} )
                {
                    die unless( $1 || $2 );

                    ($user,$repo) = ( $1 , $2 );

                    info "Found GitHub repository of $user/$repo";

                    my $_remotes = qx(git remote | grep @{[ $gh_id ]});
                    if( $_remotes ) {
                        die "Remote @{[ $gh_id ]} exists.\n";
                    }

                    my $remote_uri;
                    if ( $self->{protocol_https} ) {
                        $remote_uri = qq( https://@{[ $gh_id ]}\@github.com/@{[ $gh_id ]}/$repo.git);
                    } else {
                        $remote_uri = qq( git\@github.com:@{[ $gh_id ]}/$repo.git);
                    };
                    info "Adding remote '@{[ $gh_id ]}' => $remote_uri";

                    # url = git@github.com:c9s/App-gh.git
                    my $cmd = qq( git remote add @{[ $gh_id ]} $remote_uri);
                    _debug $cmd;
                    qx($cmd);

                    info "Remote added.";
                }
            }
        }
    }

    info "Forking...";
    my $data = App::gh::API->fork($user, $repo);

    use Data::Dumper;
    _debug Dumper( $data );

    info "Repository forked:";

    App::gh::Utils->print_repo_info($data->{repository});

    # $data = $data->{repository};
    # print "  Name:          " . $data->{name} . "\n";
    # print "  Description:   " . $data->{description} . "\n";
    # print "  Owner:         " . $data->{owner} . "\n";
    # print "  Watchers:      " . $data->{watchers} . "\n";
    # print "  Created at:    " . $data->{created_at} . "\n";
    # print "  Pushed at:     " . $data->{pushed_at} . "\n";
    # print "  Fork:          " . $data->{'fork'} . "\n";
    # print "  URL:           " . $data->{url} . "\n";
    # print "  Homepage:      " . ($data->{homepage}||'') . "\n";

}


1;
