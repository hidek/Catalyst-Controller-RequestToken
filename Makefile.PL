use inc::Module::Install;

name 'Catalyst-Controller-RequestToken';
all_from 'lib/Catalyst/Controller/RequestToken.pm';

requires 'Scalar::Util';
requires 'Digest';
requires 'MRO::Compat';
build_requires 'Catalyst::Runtime', 5.70;
build_requires 'Catalyst::Plugin::Session';
build_requires 'Catalyst::Plugin::Session::State::Cookie';
build_requires 'Catalyst::Action::RenderView';
test_requires 'Test::More';
test_requires 'ok';

WriteAll();
