#!/usr/bin/env perl
use Test::More;
use lib 'lib';
use File::Basename;
use_ok("App::gh");
use_ok("App::gh::Git");
my $version = App::gh::Git::command_oneline('version');
ok( $version , $version );

ok( App::gh::Git::command_oneline('version') );

mkdir 'test_repo';
chdir 'test_repo';

my $ret = App::gh::Git::command_oneline('init');

ok( $ret );

my $repo = App::gh->git;
ok( $repo );

ok( $repo->wc_path , $repo->wc_path );

is( 'test_repo' ,basename $repo->wc_path , 'wc_path' );

done_testing;
