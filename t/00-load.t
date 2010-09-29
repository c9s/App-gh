#!perl
use warnings;
use strict;
use lib 'lib';
use Test::More tests => 10;

BEGIN {
    use_ok( 'App::gh' ) || print "Bail out!
";

}

diag( "Testing App::gh $App::gh::VERSION, Perl $], $^X" );

use_ok( 'App::gh::Command');
use_ok( 'App::gh::Command::Network');
use_ok( 'App::gh::Command::Fork');
use_ok( 'App::gh::Command::Pull');
use_ok( 'App::gh::Command::Recent');
use_ok( 'App::gh::Command::Cloneall');
use_ok( 'App::gh::Command::Clone');
use_ok( 'App::gh::Command::Search');
use_ok( 'App::gh::Utils');
