use inc::Module::Install;

name 'Catalyst-Controller-RequestToken';
all_from 'lib/Catalyst/Controller/RequestToken.pm';

build_requires 'Catalyst::Runtime';
build_requires 'Catalyst::Plugin::Session';
test_requires 'Catalyst::Plugin::Session::State::Cookie';
test_requires 'Test::WWW::Mechanize::Catalyst';
test_requires 'Test::More';
test_requires 'ok';

WriteAll();
