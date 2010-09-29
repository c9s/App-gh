use inc::Module::Install;

name     'App-gh';
all_from 'lib/App/gh.pm';
author   q{Cornelius <cornelius.howl@gmail.com>};
license  'perl';

build_requires 'Test::More';

requires 'JSON';
# requires 'JSON::XS';
requires 'File::Temp';
requires 'App::CLI';
requires 'File::Path';
requires 'File::Spec';
requires 'LWP::Simple';
requires 'Exporter::Lite';
# requires 'POE';
# requires 'Component::AtomAggregator';
# requires 'POE::Component::SSLify';
requires 'Text::Wrap';
requires 'XML::Atom::Feed';
requires 'URI';
requires 'HTML::Strip';

install_script 'scripts/gh';

author_tests('xt');

repository 'http://github.com/c9s/App-gh';

auto_install;

WriteAll;
