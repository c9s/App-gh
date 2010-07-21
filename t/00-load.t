#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'App::ghget' ) || print "Bail out!
";
}

diag( "Testing App::ghget $App::ghget::VERSION, Perl $], $^X" );
