use inc::Module::Install;

name 'Catalyst-Controller-RequestToken';
all_from 'lib/Catalyst/Controller/RequestToken.pm';

requires 'Scalar::Util';
requires 'Class::C3';
requires 'Digest';
build_requires 'Catalyst::Runtime';
build_requires 'Catalyst::Plugin::Session';
build_requires 'Catalyst::Plugin::Session::State::Cookie';
build_requires 'Catalyst::Action::RenderView';
test_requires 'Test::More';
test_requires 'ok';

WriteAll();
