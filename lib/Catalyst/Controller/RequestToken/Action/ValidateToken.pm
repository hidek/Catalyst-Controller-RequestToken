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

=head1 NAME

Catalyst::Controller::RequestToken::Action::ValildateToken

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 INTERNAL METHODS

=over 4

=item execute

=back

=head1 SEE ALSO

L<Catalyst::Controller::RequestToken>
L<Catalyst>
L<Catalyst::Action>

=head1 AUTHOR

Hideo Kimura C<< <<hide@hide-k.net>> >>

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
1;

