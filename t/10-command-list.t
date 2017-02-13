use strict;
use warnings;

use Test::More tests => 2;

use Capture::Tiny qw/ capture_stdout /;
use List::AllUtils qw/ pairs /;

use App::gh::Command::List;

use lib 't/lib';
use Utils;

use JSON 'from_json';

Utils::test_ua();

subtest 'json' => sub {
    my $search = App::gh::Command::List->new( 
        username => 'yanick',
        format   => 'json',
    );

    my $data = from_json capture_stdout { $search->run };

    is scalar @$data => 100, 'right number of repos';
};

subtest 'summary' => sub {
    my $search = App::gh::Command::List->new( 
        username => 'yanick',
        format   => 'summary',
    );

    like capture_stdout { $search->run },
        qr/ dist-zilla \s+ - \s+ scary /x;
};
