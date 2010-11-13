package App::gh::Command::Info;
use utf8;
use warnings;
use strict;
use base qw(App::gh::Command);
use File::Path qw(mkpath);
use App::gh::Utils;
use LWP::Simple qw(get);
use JSON;



sub run {
    my $self = shift;

    # http://github.com/api/v2/yaml/repos/show/schacon/grit

}


1;
__END__

=head1 NAME

App::gh::Command::Info - show repository info

=head1 USAGE

    $ cd App
    $ gh info

=cut
