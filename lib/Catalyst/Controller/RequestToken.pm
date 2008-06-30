package Catalyst::Controller::RequestToken;

use strict;
use warnings;

use base qw(Catalyst::Controller);

use Catalyst::Exception;
use Scalar::Util qw/weaken/;
use Class::C3;
use Digest();

our $VERSION = '0.02';

sub ACCEPT_CONTEXT {
    my $self = shift;
    my $c    = shift;

    $self->{c} = $c;
    weaken( $self->{c} );

    return $self->NEXT::ACCEPT_CONTEXT( $c, @_ ) || $self;
}

sub new {
    my $class = shift;
    my ( $c, $args ) = @_;

    my $self = $class->next::method( $c, $args );

    Catalyst::Exception->throw("Catalyst::Plugin::Session is required")
        unless $c->isa('Catalyst::Plugin::Session');

    my $config = {
        session_name => '_token',
        request_name => '_token',
        %{ $c->config->{'Controller::RequestToken'} },
        %{ $class->config },
        %{$args},
    };

    $self->config($config);
    return $self;
}

sub token {
    my ( $self, $arg ) = @_;
    my $c = $self->{c};

    if ( defined $arg ) {
        $c->session->{ $self->_ident() } = $arg;
        return $arg;
    }

    return $c->session->{ $self->_ident() };
}

sub create_token {
    my ( $self, $arg ) = @_;
    my $c = $self->{c};

    $c->log->debug("create token") if $c->debug;
    my $digest = _find_digest();
    my $seed = join( time, rand(10000), $$, {} );
    $digest->add($seed);
    my $token = $digest->hexdigest;
    $c->log->debug("token is created: $token") if $c->debug;

    return $self->token($token);
}

sub remove_token {
    my ( $self, $arg ) = @_;
    my $c = $self->{c};

    $c->log->debug("remove token") if $c->debug;
    undef $c->session->{$self->_ident()};
    $self->token(undef);
}

sub validate_token {
    my ( $self, $arg ) = @_;
    my $c    = $self->{c};
    my $conf = $self->config;

    $c->log->debug('validate token') if $c->debug;
    my $session = $self->token;
    my $request = $c->req->param( $conf->{request_name} );

    $c->log->debug("session: $session");
    $c->log->debug("request: $request");

    if ( ( $session && $request ) && $session eq $request ) {
        $c->log->debug('token is valid') if $c->debug;
         $c->stash->{$self->_ident()} = 1;
    }
    else {
        $c->log->debug('token is invalid') if $c->debug;
        if ( $c->isa('Catalyst::Plugin::FormValidator::Simple') ) {
            $c->set_invalid_form( $conf->{request_name} => 'TOKEN' );
        }
        undef $c->stash->{$self->_ident()};
    }
}

sub is_valid_token {
    my ( $self, $arg ) = @_;
    my $c    = $self->{c};

    return $c->stash->{$self->_ident()};
}

sub _ident {    # secret stash key for this template'
    return '__' . ref( $_[0] ) . '_token';
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

sub _parse_CreateToken_attr {
    my ( $self, $app_class, $action_name, $vaue, $attrs ) = @_;

    return ( ActionClass =>
            'Catalyst::Controller::RequestToken::Action::CreateToken' );
}

sub _parse_ValidateToken_attr {
    my ( $self, $app_class, $action_name, $vaue, $attrs ) = @_;

    return ( ActionClass =>
            'Catalyst::Controller::RequestToken::Action::ValidateToken' );
}

sub _parse_RemoveToken_attr {
    my ( $self, $app_class, $action_name, $vaue, $attrs ) = @_;

    return ( ActionClass =>
            'Catalyst::Controller::RequestToken::Action::RemoveToken' );
}

sub _parse_ValidateRemoveToken_attr {
    my ( $self, $app_class, $action_name, $vaue, $attrs ) = @_;

    return ( ActionClass =>
            'Catalyst::Controller::RequestToken::Action::ValidateRemoveToken'
    );
}

1;

__END__

=head1 NAME

Catalyst::Controller::RequestToken - Handling transaction token across forms

=head1 SYNOPSIS

requires Catalyst::Plugin::Session module, in your application class:

    use Catalyst qw/
        Session
        Session::State::Cookie
        Session::Store::FastMmap
        FillInForm
     /;

in your controller class:

    use base qw(Catalyst::Controller::RequestToken);
    
    sub form :CreateToken {
        my ($self, $c) = @_;
        $c->stash->{template} = 'form.tt';
        $c->forward($c->view('TT'));
    }
    
    sub confirm :Local :ValidateToken {
        my ($self, $c) = @_;
        $c->stash->{template} = 'confirm.tt';
        $c->forward($c->view('TT'));
    }
    
    sub complete :Local :ValidateRemoveToken {
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
    <input type="hidden" name="_token" values="[% c.req.param('_token') %]"/>
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

=head1 ATTRIBUTES

=over 4

=item CreateToken

Creates new token and put it into request and session. 
You can return a content with request token which should be posted 
to server.

=item ValidateToken

After CreateToken, clients will post token request, so you need
validate it correct or not.

ValidateToken attribute validates request token with session token 
which is created by CreateToken attribute.

=item RemoveToken

Removes token from session, then request token will be invalid any more.

= item ValidateRemoveToken 
Works as combination of ValidateToken and RemoveToken.
This will be useful for the last part of transaction.

=back

=head1 METHODS

=over 4

=item token

=item create_token

=item remove_token

=item validate_token

Return token is valid or not.  This will work collectlly only after
ValidateToken.

=item is_valid_token

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

=item validate_stash_name

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

