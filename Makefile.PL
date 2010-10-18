use inc::Module::Install;

name     'App-gh';
all_from 'lib/App/gh.pm';
author   q{Cornelius <cornelius.howl@gmail.com>};
license  'perl';

build_requires 'Test::More';

requires 'File::Temp';
requires 'App::CLI';
requires 'File::Path';
requires 'File::Spec';
requires 'LWP::Simple';
requires 'URI';
requires 'Text::Wrap';
requires 'URI';
requires 'JSON';
requires 'JSON::XS';
requires 'HTML::Strip';
# requires 'IO::Pager';

install_script 'scripts/gh';

author_tests('xt');

repository 'http://github.com/c9s/App-gh';

auto_install;

WriteAll;
