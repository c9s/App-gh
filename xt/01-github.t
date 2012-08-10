#!/usr/bin/env perl
use Test::More;
use App::gh;
my $github = App::gh->github;
ok $github , 'net-github';
ok $github->repos , 'repos';
ok $github->repos->list;

my $user = $github->user->show('nothingmuch');
ok $user, 'user';

done_testing;
