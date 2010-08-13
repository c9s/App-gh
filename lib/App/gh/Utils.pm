package App::gh::Utils;
use warnings;
use strict;
use base qw(Exporter);

use constant debug => $ENV{DEBUG};

our @EXPORT = qw(_debug _info
    parse_config parse_options get_github_auth);

sub _debug {
    print STDERR @_,"\n" if debug;
}

sub _info {
    print STDERR @_,"\n";
}


sub parse_config {
    my ($file) = @_;
    open FH , "<" , $file;
    local $/;
    my $content = <FH>;
    close FH;
    my @parts = split /(?=\[.*?\])/,$content;


    my %config;

    for my $part ( @parts ) {
        if( $part =~ /^\[(\w+)\s+["'](\w+)["']\]/g ) {
            my ($o1 , $o2 ) = ($1, $2);
            $config{ $o1 } ||= {};
            $config{ $o1 }->{ $o2 } 
                = parse_options( $part );
        }
        elsif( $part =~ /^\[(.*?)\]/g  ) {
            my $key = $1;
            my $options = parse_options( $part );
            $config{ $key } = $options;
        }
    }
    return \%config;
}

sub parse_options {
    my $part = shift;
    my $options;
    while(  $part =~ /^\s*(.*?)\s*=\s*(.*?)\s*$/gm ) {
        my ($name,$value) = ($1,$2);
        $options->{ $name } = $value;
    }
    return $options;
}

sub get_github_auth {
    my $config = parse_config $ENV{HOME} . "/.gitconfig";
    return $config->{github};
}

1;
