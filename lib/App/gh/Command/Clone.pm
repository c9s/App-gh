package App::gh::Command::Clone;
use warnings;
use strict;
use base qw(App::gh::Command);
use App::gh::Utils;
use LWP::Simple qw(get);
use App::gh::Utils;
use JSON;

sub run {
    my ($self) = shift;
    my $user;
    my $repo;

    $user = shift;
    if( $user =~ /\// ) {
        ( $user, $repo ) = split /\//, $user;
    }
    else {
        $repo = shift;
    }

    unless( $user && $repo ) {
        die "Usage [user] [repo]";
    }

    my $attr = shift || 'ro';
    my $uri;
    if( $attr eq 'ro' ) {
        $uri = sprintf "git://github.com/%s/%s.git" , $user , $repo;
    }
    elsif( $attr eq 'ssh' ) {
        $uri = sprintf "git\@github.com:%s/%s.git" , $user , $repo;
    }
    print $uri . "\n";
    system( qq{git clone $uri} );
}

1;
