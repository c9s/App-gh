use inc::Module::Install;

name     'App-gh';
all_from 'lib/App/gh.pm';
author   q{Cornelius <cornelius.howl@gmail.com>};
license  'perl';

build_requires 'Test::More';

requires 'Term::ANSIColor';
requires 'File::Temp';
requires 'File::Basename';
requires 'App::CLI';
requires 'File::Path';
requires 'File::Spec';
requires 'File::HomeDir';
requires 'LWP::Simple';
requires 'URI';
requires 'Text::Wrap';
requires 'JSON::XS';
requires 'HTML::Strip';
requires 'Term::ReadLine';
requires 'Scope::Guard';
requires 'Error';
requires 'Try::Tiny';
requires 'Net::GitHub';
requires 'IO::Pager';
requires 'LWP::Protocol::https';

# `gh recent` support
recommends 'XML::Atom';
recommends 'IO::Socket::SSL';

install_script 'scripts/gh';

author_tests('xt');

repository 'http://github.com/c9s/App-gh';
bugtracker 'http://github.com/c9s/App-gh/issues';

auto_install;

WriteAll;
