package Catalyst::Controller::RequestToken::Action::CreateToken;

use strict;
use warnings;

use base qw(Catalyst::Action);

use Catalyst::Exception;
use Digest();

sub execute {
    my $self = shift;
    my ( $controller, $c, @args ) = @_;

    $c->log->debug("create token") if $c->debug;
    my $digest = _find_digest();
    my $seed = join( time, rand(10000), $$, {} );
    $digest->add($seed);
    my $token = $digest->hexdigest;
    $c->log->debug("token is created: $token") if $c->debug;

    my $conf = $controller->config;
    $c->session->{ $conf->{session_name} } = $token;
    $c->request->params->{ $conf->{request_name} } = $token;

    return $self->NEXT::execute(@_);
}

# following code is from Catalyst::Plugin::Session
my $usable;

sub _find_digest () {
    unless ($usable) {
        foreach my $alg (qw/SHA-256 SHA-1 MD5/) {
            if ( eval { Digest->new($alg) } ) {
                $usable = $alg;
                last;
            }
        }
        Catalyst::Exception->throw(
                  "Could not find a suitable Digest module. Please install "
                . "Digest::SHA1, Digest::SHA, or Digest::MD5" )
            unless $usable;
    }

    return Digest->new($usable);
}

1;

