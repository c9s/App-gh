#!/usr/bin/env perl
use Test::More;
use App::gh;
my $github = App::gh->github;
ok $github;

done_testing;
