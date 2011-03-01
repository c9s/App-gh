#!/usr/bin/env perl
use Test::More tests => 1;
use lib 'lib';
use_ok("App::gh::Git");
my $version = Git::command_oneline('version');
ok( $version , $version );
