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




# XXX: use Config::Tiny to parse ini format config.
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

# when command trying to read config, we should let it die, and provide another
# method to check github id and token.
# XXX: abandoned, since we are using Net::GitHub V3
sub github_token {
    return $_[0]->global()->{github}->{token};
}

sub github_id {
    return $_[0]->global()->{github}->{user};
}

sub global {
    my $class = shift;
    my $path = File::Spec->join(File::HomeDir->my_home, '.gitconfig');
    return unless -e $path;
    return $class->parse( $path );
}

1;
