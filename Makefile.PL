use inc::Module::Install;

name     'App-gh';
all_from 'lib/App/gh.pm';
author   q{Cornelius <cornelius.howl@gmail.com>};
license  'perl';

build_requires 'Test::More';

requires 'File::Temp';
requires 'File::Basename';
requires 'App::CLI';
requires 'File::Path';
requires 'File::Temp';
requires 'File::Spec';
requires 'File::HomeDir';
requires 'LWP::Simple';
requires 'URI';
requires 'Text::Wrap';
requires 'URI';
requires 'JSON';
requires 'JSON::XS';
requires 'HTML::Strip';
requires 'Term::ReadLine';
requires 'Scope::Guard';
requires 'Error::Simple';
requires 'Error';

# `gh recent` support
recommends 'IO::Pager';
recommends 'XML::Atom';
recommends 'IO::Socket::SSL';

install_script 'scripts/gh';

author_tests('xt');

repository 'http://github.com/c9s/App-gh';
bugtracker 'http://github.com/c9s/App-gh/issues';

auto_install;

WriteAll;
