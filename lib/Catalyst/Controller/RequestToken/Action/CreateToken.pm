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

=head1 NAME

Catalyst::Controller::RequestToken::Action::CreateToken

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

