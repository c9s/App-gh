#!/usr/bin/env perl
use Test::More;
use lib 'lib';
use_ok("App::gh");
use_ok("App::gh::Git");
use_ok("App::gh::Command");
done_testing;
