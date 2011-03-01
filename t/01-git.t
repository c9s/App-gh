#!/usr/bin/env perl
use Test::More tests => 1;
use lib 'lib';
require App::gh::Git;

use_ok("Git");
