#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'App::gh' ) || print "Bail out!
";
}

diag( "Testing App::gh $App::gh::VERSION, Perl $], $^X" );
