package App::gh::Command;
use warnings;
use strict;
use App::gh::Utils;

sub require_global_gitconfig { 0 }

sub require_local_gitconfig { 0 }

sub require_github_auth { 0 }

sub new {
    my $class = shift;
    return bless $class , {};
}

sub dispatch {
    my ($class,$cmd,@args) = @_;
    my $cmd_class = __PACKAGE__ . "::" . ucfirst( $cmd );

    # eval "require $cmd_class.pm;";

    my $xd = $cmd_class->new();

    if( $xd->require_local_gitconfig ) {
        die "Git config not found." if ( ! -e ".git/config" );
    }
    if( $xd->require_github_auth ) {

    }
    $xd->run( @args );



}


1;
