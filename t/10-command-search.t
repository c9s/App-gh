use strict;
use warnings;

use Test::More tests => 1;

use Capture::Tiny qw/ capture_stdout /;
use List::AllUtils qw/ pairs /;

use App::gh::Command::Search;

use lib 't/lib';
use Utils;

Utils::test_ua();


my $search = App::gh::Command::Search->new( 
    query  => 'MoobX',
);

like capture_stdout { $search->run } 
    => qr#yanick/MoobX \s+ - \s+ something \s something \s something#x;
