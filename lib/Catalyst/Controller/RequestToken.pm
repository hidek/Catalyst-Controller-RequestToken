package Catalyst::Controller::RequestToken;

use strict;
use warnings;

use base qw(Catalyst::Controller);

our $VERSION = '0.01';

__PACKAGE__->config(
        session_name => '_token',
        request_name => '_token',
);

sub ACCEPT_CONTEXT {
    my ( $self, $c ) = @_;

    return bless { %$self, c => $c }, ref($self);
}

sub new {
    my $class = shift;
    my $self  = $class->NEXT::new(@_);

    $self->_setup(@_);
    return $self;
}

sub _setup {
    my $self = shift;
    my ($c) = @_;

    $self->config(%{$self->config}, %{$c->config->{'Controller::RequestToken'}});

    Catalyst::Exception->throw("Catalyst::Plugin::Session is required")
        unless $c->isa('Catalyst::Plugin::Session');
}

sub validate_token {
    my $self = shift;

    return $self->{c}->stash->{validate_token};
}

sub _parse_CreateToken_attr {
    my ( $self, $app_class, $action_name, $vaue, $attrs ) = @_;

    return ( ActionClass => 'Catalyst::Controller::RequestToken::Action::CreateToken' );
}

sub _parse_ValidateToken_attr {
    my ( $self, $app_class, $action_name, $vaue, $attrs ) = @_;

    return ( ActionClass => 'Catalyst::Controller::RequestToken::Action::ValidateToken' );
}

=head1 NAME

Catalyst::Controller::RequestToken - Handling transaction token across forms

=head1 SYNOPSIS

requires Catalyst::Plugin::Session module, in your application class:

    use Catalyst qw/
        Session
        Session::State::Cookie
        Session::Store::FastMmap
        FillForm
     /;

in your controller class:

    use base qw(Catalyst::Controller::RequestToken);
    
    sub form :Local {
        my ($self, $c) = @_;
        $c->stash->{template} = 'form.tt';
        $c->forward($c->view('TT'));
    }
    
    sub confirm :Local :CreateToken {
        my ($self, $c) = @_;
        $c->stash->{template} = 'confirm.tt';
        $c->forward($c->view('TT'));
    }
    
    sub complete :Local :ValidateToken {
        my ($self, $c) = @_;
        if ($self->validate_token) {
            $c->response->body('complete.');
        } eles {
            $c->response->body('invalid operation.');
        }    
    }

form.tt

    <html>
    <body>
    <form action="confirm" method="post">
    <input type="submit" name="submit" value="confirm"/>
    </form>
    </body>
    </html>

confirm.tt

    <html>
    <body>
    <form action="complete" method="post">
    <input type="hidden" name="_token" values="[% c.req.param('_token') %]"/>
    <input type="submit" name="submit" value="complete"/>
    </form>
    </body>
    </html>

=head1 DESCRIPTION

This controller enables to enforcing a single transaction across multi forms.
Using token, you can prevent duplicate submits, or protect from CSRF atack.

This module REQUIRES Catalyst::Plugin::Session to store server side token.

If you add CreateToken attribute to action, token will be created and stored
into request and session. You can return a content with request token which
should be posted to server.

If you add ValidateToken attribute, this will validate request token with 
sever-side session token, and remove token from session.

After ValidateToken, there is any token in session, so validation will be
failed, if user request with expired token.

=head1 METHODS

=over 4

=item validate_token

Return token is valid or not.  This will work collectlly only after
ValidateToken.

=back

=head1 CONFIGRATION

in your application class:

    __PACKAGE__->config('Controller::RequestToken' => {
        session_name => '_token',
        request_name => '_token',
    });

=over 4

=item session_name

Default: _token

=item request_name

Default: _token

=back

=head1 INTERNAL METHODS

=over 4

=item new

=item ACCEPT_CONTEXT

=back

=head1 SEE ALSO

L<Catalyst::Controller::RequestToken::Action::CreateToken>
L<Catalyst::Controller::RequestToken::Action::ValidateToken>
L<Catalyst>
L<Catalyst::Controller>
L<Catalyst::Plugin::Session>
L<Catalyst::Plugin::FormValidator::Simple>

=head1 AUTHOR

Hideo Kimura C<< <<hide@hide-k.net>> >>

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut

1;
