package App::gh::Utils;
use warnings;
use strict;
use base qw(Exporter);

use constant debug => $ENV{DEBUG};

my $screen_width = 92;

our @EXPORT = qw(_debug _info
    parse_config parse_options get_github_auth print_list);

# XXX: move this to logger....... orz
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

sub print_list {
    my @lines = @_;

    my $column_w = 0;

    map { 
        $column_w = length($_->[0]) if length($_->[0]) > $column_w ; 
    } @lines;

    for my $arg ( @lines ) {
        my $title = shift @$arg;

        my $padding = int($column_w) - length( $title );

        if ( $ENV{WRAP} && ( $column_w + 3 + length( join " ",@$arg) ) > $screen_width ) {
            # wrap description
            my $string = $title . " " x $padding . " - " . join(" ",@$arg) . "\n";
            $string =~ s/\n//g;

            my $cnt = 0;
            my $firstline = 1;
            my $tab = 4;
            my $wrapped = 0;
            while( $string =~ /(.)/g ) {
                $cnt++;

                my $c = $1;
                print $c;

                if( $c =~ /[ \,]/ && $firstline && $cnt > $screen_width ) {
                    print "\n" . " " x ($column_w + 3 + $tab );
                    $firstline = 0;
                    $cnt = 0;
                    $wrapped = 1;
                }
                elsif( $c =~ /[ \,]/ && ! $firstline && $cnt > ($screen_width - $column_w) ) {
                    print "\n" . " " x ($column_w + 3 + $tab );
                    $cnt = 0;
                    $wrapped = 1;
                }
            }
            print "\n";
            print "\n" if $wrapped;
        }
        else { print $title;
            print " " x $padding;
            print " - ";
            print join " " , @$arg;
            print "\n";
        }

    }
}


1;
