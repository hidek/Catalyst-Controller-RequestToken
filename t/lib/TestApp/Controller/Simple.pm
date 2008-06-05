package TestApp::Controller::Simple;
use strict;
use warnings;

use base 'Catalyst::Controller::RequestToken';

sub form : Local CreateToken {
    my ( $self, $c ) = @_;

    $c->stash->{html} = <<HTML;
<html>
<head></head>
<body>
FORM
<form action="confirm" method="post">
<input type="hidden" name="_token" value="TOKEN"/>
<input type="submit" name="submit" value="submit"/>
</form>
</body>
</html>
HTML

    $c->forward('parse_html');
}

sub confirm : Local ValidateToken {
    my ( $self, $c ) = @_;

    $c->stash->{html} = <<HTML;
<html>
<body>
CONFIRM
<form action="complete" method="post">
<input type="hidden" name="_token" value="TOKEN"/>
<input type="submit" name="submit" value="submit"/>
</form>
</body>
</html>
HTML
    $c->detach('error') unless $self->validate_token;
    $c->forward('parse_html');
}

sub complete : Local ValidateRemoveToken {
    my ( $self, $c ) = @_;

    $c->stash->{html} = <<HTML;
<html><body>SUCCESS</body></html>
HTML

    $c->detach('error') unless $self->validate_token;
    $c->forward('parse_html');
}

sub error : Local {
    my ( $self, $c ) = @_;

    my $html = <<HTML;
<html><body>INVALID ACCESS</body></html>
HTML

    $c->response->body($html);
}

sub parse_html : Private {
    my ( $self, $c ) = @_;
    my $token = $c->req->param('_token');

    my $html = $c->stash->{html};
    $html =~ s/TOKEN/$token/g;
    $c->response->body($html);
}

1;
