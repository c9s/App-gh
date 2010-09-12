package App::gh::Command::Cloneall;
use warnings;
use strict;
use base qw(App::gh::Command);
use File::Path qw(mkpath);
use App::gh::Utils;
use LWP::Simple qw(get);
use JSON;

sub options { (
        "verbose" => "verbose",
        "into=s" => "into"
    ) }

sub run {
    my $self = shift;
    my $acc = shift;
    my $attr = shift || 'ro';

    if( $self->{into} ) {
        _info "Cloning all repositories into @{[ $self->{into} ]}";

        mkpath [ $self->{into} ];
        chdir  $self->{into};
    }

    die 'need id' unless $acc;

    _info "Getting repository list from github: $acc" if $self->{verbose};
    my $json = get 'http://github.com/api/v2/json/repos/show/' . $acc;
    my $data = decode_json( $json );

    _info "Will clone repositories below:";
    print " " x 8 . join " " , map { $_->{name} } @{ $data->{repositories} };
    print "\n";

    for my $repo ( @{ $data->{repositories} } ) {
        my $repo_name = $repo->{name};
        my $local_repo_name = $repo_name;
        $local_repo_name =~ s/\.git$//;

        my $uri;
        if( $attr eq 'ro' ) {
            $uri = sprintf "git://github.com/%s/%s.git" , $acc , $repo_name;
        }
        elsif( $attr eq 'ssh' ) {
            $uri = sprintf "git\@github.com:%s/%s.git" , $acc , $repo_name;
        }
        print $uri . "\n" if $self->{verbose};

        if( -e $local_repo_name ) {
            print "Updating " . $local_repo_name . " ...\n";
            qx{ cd $local_repo_name ; git pull --rebase origin master };
        }
        else {
            print "Cloning " . $repo->{name} . " ...\n";
            qx{ git clone -q $uri };
        }
    }




}


1;