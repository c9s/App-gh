package App::gh::Utils;
use warnings;
use strict;
use base qw(Exporter);
use Term::ANSIColor;
use URI;

use constant debug => $ENV{DEBUG};


our @EXPORT = qw(_debug
    info 
    error
    notice
    get_github_auth print_list
);
our @EXPORT_OK = qw(
    generate_repo_uri 
    git_current_branch
    run_git_fetch
    build_git_clone_command
    build_git_fetch_command
    build_git_remote_command
    dialog_yes_default
);

sub build_git_fetch_command;

# XXX: move this to logger....... orz
sub _debug {
    print STDERR @_,"\n" if debug;
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

    my $screen_width = 92;

    for my $arg ( @lines ) {
        my $title = shift @$arg;
        my $padding = int($column_w) - length( $title );

        if ( $ENV{WRAP} && ( $column_w + 3 + length( join(" ",@$arg)) ) > $screen_width ) {
            # wrap description
            my $string = 
                color('bold') . 
                $title .
                color('reset') . 
                " " x $padding . " - " . join(" ",@$arg) . "\n";

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
        else { 
            print color 'bold';
            print $title;
            print color 'reset';
            print " " x $padding;
            print " - ";
            $$arg[0] = ' ' unless $$arg[0];
            print join " " , @$arg;
            print "\n";
        }

    }
}



sub error {
    my @msg = @_;
    print STDERR color 'red';
    print STDERR join("\n", @msg), "\n";
    print STDERR color 'reset';
}

sub info { 
    my @msg = @_;
    print STDERR color 'green';
    print STDERR join("\n", @msg), "\n";
    print STDERR color 'reset';
}

sub notice {
    my @msg = @_;
    print STDERR color 'bold yellow';
    print STDERR join("\n", @msg), "\n";
    print STDERR color 'reset';
}


#
# @param string $remote git remote name
# @param hashref $options  
# @return string command output
sub run_git_fetch {
    my @command = build_git_fetch_command @_;
    my $cmd = join ' ' , @command;
    my $result = qx($cmd);
    return $result;
}


# 
# @param string $remote Git remote name
# @param hashref $options 
# @return array command list
sub build_git_fetch_command {
    my ($remote,$options) = (undef,{});
        $remote = shift if ref($_[0]) ne 'HASH';
        $options = shift if ref($_[0]) eq 'HASH';
    my @command = qw(git fetch);
    push @command, $remote      if $remote;
    push @command, '--all'      if $options->{all};
    push @command, '--multiple' if $options->{multiple};
    push @command, '--tags'     if $options->{tags};
    push @command, '--quiet'    if $options->{quiet};
    push @command, '--verbose'  if $options->{verbose};
    push @command, '--recurse-submodules=' 
            . ($options->{submodules} || 'yes')
                if $options->{submodules};
    return @command;
}

sub build_git_remote_command {
    my ($subcommand,@args,$options);
    $subcommand = shift if ! ref $subcommand;

    push @args, shift(@_) while $_[0] && ! ref $_[0];
    $options    = shift if ref $_[0] eq 'HASH';
    $options    ||= {};

    my @command = qw(git remote);

    push @command, '--verbose' if $options->{verbose};
    push @command, $subcommand if $subcommand;

    # git remote update
    if( $subcommand =~ /update/ ) {
        push @command, '--prune' if $options->{prune};
    }
    elsif( $subcommand =~ /prune/ ) {
        push @command, '--dry-run' if $options->{dry_run};
    }
    push @command, @args if @args;
    return @command;
}


# 
# @param string $uri
# @param hashref $options default { }
# @return array command list
sub build_git_clone_command { 
    my $uri = shift;;
    my $options = shift || {};
    my @command = qw(git clone);
    push @command, '--bare'                         if $options->{bare};
    push @command, '--branch=' . $options->{branch} if $options->{branch};
    push @command, '--quiet'                        if $options->{quiet};
    push @command, '--mirror'                       if $options->{mirror};
    push @command, '--recursive'                    if $options->{recursive};
    push @command, '--origin=' . $options->{origin} if $options->{origin};
    push @command, '--verbose' if $options->{verbose};
    push @command, $uri;
    return @command;
}

sub git_current_branch {
    my $ref = qx(git rev-parse --abbrev-ref HEAD);
    chomp($ref);
    return $ref;
}

#
# @param string $user
# @param string $repo
# @param hashref $options
# return string GitHub Clone URI
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


#
# @param string $msg
# @return boolean
sub dialog_yes_default {
    my $msg = shift;
    local $|;
    print STDERR $msg;
    print STDERR ' (Y/n) ';

    my $a = <STDIN>;
    chomp $a;
    if($a =~ /n/) {
        return 0;
    }
    return 1 if $a =~ /y/;
    return 1; # default to Y
}


1;
