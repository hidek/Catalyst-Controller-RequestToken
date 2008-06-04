package Catalyst::Controller::RequestToken::Action::ValidateToken;

use strict;
use warnings;

use base qw(Catalyst::Action);

use Catalyst::Exception;

sub execute {
    my $self = shift;
    my ( $controller, $c, @args ) = @_;

    my $conf = $controller->config;

    $c->log->debug('validate token') if $c->debug;
    my $session = $c->session->{ $conf->{session_name} };
    my $request = $c->req->param( $conf->{request_name} );

    if ( ( $session && $request ) && $session eq $request ) {
        $c->stash->{validate_token} = 1;
        $c->log->debug('token is valid') if $c->debug;
    } else {
        $c->log->debug('token is invalid') if $c->debug;
        if ( $c->isa('Catalyst::Plugin::FormValidator::Simple') ) {
            $c->set_invalid_form(
                $conf->{request_name} => 'TOKEN' );
        }
    }

    undef $c->session->{ $conf->{session_name} };
    return $self->NEXT::execute(@_);
}

1;

