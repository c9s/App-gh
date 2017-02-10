package Utils;

use strict;
use warnings;

use Test::LWP::UserAgent;
use Path::Tiny;
use List::AllUtils qw/ pairmap pairgrep /;

our %url_mapping = (
    'search/repositories' => 'search.json',
);

my $ua = Test::LWP::UserAgent->new;

sub test_ua { $App::gh::TEST_UA = $ua; }
$App::gh::TEST_UA = $ua; 

my $corpus = path('t/corpus');

$ua->map_response(
    qr// => sub {
        my $request = $_[0];

        my ( $file ) = 
            pairmap  { $b }
            pairgrep { -1 < index $request->as_string, $a  } %url_mapping;

        unless( $file ) {
            warn "request not caught: ", $request->as_string;
            return HTTP::Response->new(404);
        }
    
        return HTTP::Response->new(
            200,
            undef,
            HTTP::Headers->new( 
                'Content-Type'          => 'application/json',
                'x-ratelimit-remaining' => 10_000,
            ),
            $corpus->child($file)->slurp
        ),
    }
);

1;


