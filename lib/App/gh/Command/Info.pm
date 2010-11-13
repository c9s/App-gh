package App::gh::Command::Info;
use utf8;
use warnings;
use strict;
use base qw(App::gh::Command);
use File::Path qw(mkpath);
use App::gh::Utils;
use LWP::Simple qw(get);
use JSON;

sub prop_line {
    my ( $label, $value ) = @_;
    printf "%15s: %s\n", $label, $value;
}

sub run {
    my $self = shift;
    my $ret = App::gh->api->repo_info( 'c9s' , 'App-gh' );

    prop_line "Name" , $ret->{name};
    prop_line "Description" , $ret->{description};
    prop_line "Owner" , $ret->{owner};
    prop_line "URL"   , $ret->{url};

    prop_line "Watchers"   , $ret->{watchers};
    prop_line "Forks"      , $ret->{forks};
    prop_line "Open Issues"     , $ret->{open_issues};
    prop_line "Created at" , $ret->{created_at};
    prop_line "Pushed at"  , $ret->{pushed_at};

    print ' ' x 15 . "* Is private\n"    if $ret->{private};
    print ' ' x 15 . "* Has downloads\n" if $ret->{has_downloads};
    print ' ' x 15 . "* Has issues\n"    if $ret->{has_issues};

}


1;
__END__

=head1 NAME

App::gh::Command::Info - show repository info

=head1 USAGE

    $ cd App
    $ gh info

=cut
