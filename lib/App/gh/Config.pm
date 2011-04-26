package App::gh::Config;
use warnings;
use strict;
use File::HomeDir ();
use File::Spec;

sub _parse_options {
    my $part = shift;
    my $options;
    while(  $part =~ /^\s*(.+?)\s*=\s*(.*?)\s*$/gm ) {
        my ($name,$value) = ($1,$2);
        $options->{ $name } = $value;
    }
    return $options;
}


sub parse {
    my ( $class, $file ) = @_;

    # read file
    open FH , "<" , $file;
    local $/;
    my $content = <FH>;
    close FH;

    # TODO: simply parse config.... better choice ?
    my @parts = split /(?=\[.*?\])/,$content;
    my %config;
    for my $part ( @parts ) {
        if( $part =~ /^\[(\w+)\s+["'](\w+)["']\]/g ) {
            my ($o1 , $o2 ) = ($1, $2);
            $config{ $o1 } ||= {};
            $config{ $o1 }->{ $o2 }
                = _parse_options( $part );
        }
        elsif( $part =~ /^\[(.*?)\]/g  ) {
            my $key = $1;
            my $options = _parse_options( $part );
            $config{ $key } = $options;
        }
    }
    return \%config;
}


sub current {
    my $class = shift;
    my $path = File::Spec->join(".git","config");
    return unless -e $path;

    # TODO: prevent error
    return $class->parse( $path );
}

sub github_token {
    my $class = shift;
    my $config;
    $config = $class->global();
    return $config->{github}->{token};
}

sub github_id {
    my $class = shift;
    my $config;
    $config = $class->global();
    return $config->{github}->{user};
}


sub global {
    my $class = shift;
    my $path = File::Spec->join(File::HomeDir->my_home, '.gitconfig');
    return unless -e $path;
    return $class->parse( $path );
}

1;
