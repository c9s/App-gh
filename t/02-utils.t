#!/usr/bin/env perl
use Test::More;
use App::gh::Utils qw(build_git_remote_command);

my @cmds;

@cmds = build_git_remote_command('update',{ });
ok @cmds;
is 3,scalar @cmds;
is_deeply [ qw(git remote update) ], \@cmds;

# git prune origin
@cmds = build_git_remote_command('prune','origin',{ });
ok @cmds;
is 4,scalar @cmds;
is_deeply [ qw(git remote prune origin) ], \@cmds;

done_testing;
