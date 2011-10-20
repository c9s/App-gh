#!perl
use warnings;
use strict;
use lib 'lib';
use Test::More;

BEGIN {
    use_ok( 'App::gh' ) || print "Bail out!";
}

diag( "Testing App::gh $App::gh::VERSION, Perl $], $^X" );

use_ok( 'App::gh::Command');
use_ok( 'App::gh::Command::Network');
use_ok( 'App::gh::Command::Fork');
use_ok( 'App::gh::Command::Pull');
# use_ok( 'App::gh::Command::Recent');
use_ok( 'App::gh::Command::All');
use_ok( 'App::gh::Command::Clone');
use_ok( 'App::gh::Command::Search');
use_ok( 'App::gh::Utils');
use_ok( 'App::gh::Command::Import');
use_ok( 'App::gh::Command::Drop');
use_ok( 'App::gh::Command::Pull');
use_ok( 'App::gh::Command::Push');
use_ok( 'App::gh::Command::Update');
use_ok( 'App::gh::Command::Info');
use_ok( 'App::gh::Command::Setup');
use_ok( 'App::gh::Command::Pullreq');
use_ok( 'App::gh::Command::Pullreq::List');
use_ok( 'App::gh::Command::Pullreq::Send');
use_ok( 'App::gh::Command::Pullreq::Show');

done_testing;
