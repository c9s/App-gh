use inc::Module::Install;

name     'App-gh';
all_from 'lib/App/gh.pm';
author   q{Cornelius <cornelius.howl@gmail.com>};
license  'perl';

build_requires 'Test::More';

requires 'JSON';
requires 'JSON::XS';
requires 'LWP::Simple';
requires 'File::Temp';

install_script 'scripts/gh';

auto_install;

WriteAll;

