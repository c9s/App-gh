package App::Command;
use warnings;
use strict;

sub new {
    my $class = shift;
    return bless $class , {};
}

sub dispatch {
    my ($class,$cmd,@args) = @_;
    my $cmd_class = __PACKAGE__ . "::" . ucfirst( $cmd );
    my $xd = $cmd_class->new();
    $xd->run( @args );
}


1;
