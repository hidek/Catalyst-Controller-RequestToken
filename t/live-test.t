#!/usr/bin/env perl

use strict;
use warnings;
use Test::More tests => 15;

# setup library path
use FindBin qw($Bin);
use lib "$Bin/lib";

# make sure testapp works
use ok 'TestApp';

# a live test against TestApp, the test application
use Test::WWW::Mechanize::Catalyst 'TestApp';
my $mech = Test::WWW::Mechanize::Catalyst->new;
$mech->get_ok('http://localhost/', 'get main page');
$mech->content_like(qr/it works/i, 'see if it has our text');

$mech->get_ok('http://localhost/simple/form', 'get main page');
$mech->content_like(qr/FORM/i, 'see if it has our text');

$mech->submit_form_ok({}, 'submit form');
$mech->content_like(qr/CONFIRM/i, 'see if it has our text');

$mech->submit_form_ok({}, 'submit form');
$mech->content_like(qr/SUCCESS/i, 'see if it has our text');

$mech->reload;
$mech->content_like(qr/FAIL/i, 'see if it has our text');

$mech->back;
$mech->content_like(qr/CONFIRM/i, 'see if it has our text');

$mech->submit;
$mech->content_like(qr/FAIL/i, 'see if it has our text');

$mech->back;
$mech->back;
$mech->content_like(qr/FORM/i, 'see if it has our text');
$mech->submit;
$mech->content_like(qr/CONFIRM/i, 'see if it has our text');
$mech->submit;
$mech->content_like(qr/SUCCESS/i, 'see if it has our text');
