#!perl
use lib 'lib';
use Test::More tests => 5;

BEGIN {
    use_ok( 'App::gh' ) || print "Bail out!
";

}

diag( "Testing App::gh $App::gh::VERSION, Perl $], $^X" );

use_ok( 'App::gh::Command');
use_ok( 'App::gh::Command::Network');
use_ok( 'App::gh::Command::Fork');
use_ok( 'App::gh::Command::Pull');
