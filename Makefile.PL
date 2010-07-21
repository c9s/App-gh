use inc::Module::Install;

name     'App-ghget';
all_from 'lib/App/ghget.pm';
author   q{Cornelius <cornelius.howl@gmail.com>};
license  'perl';

build_requires 'Test::More';

install_script 'scripts/ghget';

auto_install;

WriteAll;

