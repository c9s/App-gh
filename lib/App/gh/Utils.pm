package App::gh::Utils;
use warnings;
use strict;
use base qw(Exporter);
use URI;

use constant debug => $ENV{DEBUG};

my $screen_width = 92;

our @EXPORT = qw(_debug _info get_github_auth print_list);
our @EXPORT_OK = qw(generate_repo_uri);

# XXX: move this to logger....... orz
sub _debug {
    print STDERR @_,"\n" if debug;
}

sub _info {
    print STDERR @_,"\n";
}

sub prop_line {
    my ( $label, $value ) = @_;
    printf "%15s: %s\n", $label, $value;
}

sub print_repo_info {
    my ( $class, $ret ) = @_;
    prop_line "Name" , $ret->{name};
    prop_line "Description" , $ret->{description};
    prop_line "Owner" , $ret->{owner};
    prop_line "URL"   , $ret->{url};

    prop_line "Watchers"   , $ret->{watchers};
    prop_line "Forks"      , $ret->{forks};
    prop_line "Open Issues"     , $ret->{open_issues};
    prop_line "Created at" , $ret->{created_at};
    prop_line "Pushed at"  , $ret->{pushed_at} || "never";

    prop_line "Parent"     , $ret->{parent} if( $ret->{parent} );

    print ' ' x 15 . "* Is private\n"    if $ret->{private};
    print ' ' x 15 . "* Has downloads\n" if $ret->{has_downloads};
    print ' ' x 15 . "* Has issues\n"    if $ret->{has_issues};
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
            $$arg[0] = ' - ' unless $$arg[0];
            print join " " , @$arg;
            print "\n";
        }

    }
}



sub generate_repo_uri { 
    my ($user,$repo,$options) = @_;

    $options->{protocol_ssh} = 1 
        if App::gh->config->github_id eq $user;

    if( $options->{protocol_git} ) {
        return sprintf( 'git://github.com/%s/%s.git', $user, $repo );
    }
    elsif( $options->{protocol_ssh} ||
        $options->is_mine($user, $repo) ) {
        return sprintf( 'git@github.com:%s/%s.git', $user, $repo );
    }
    elsif( $options->{protocol_http} ) {
        return sprintf( 'http://github.com/%s/%s.git', $user , $repo );
    }
    elsif( $options->{protocol_https}) {
        return sprintf( 'https://github.com/%s/%s.git', $user , $repo );
    }
    return sprintf( 'git://github.com/%s/%s.git', $user, $repo );
}



1;
