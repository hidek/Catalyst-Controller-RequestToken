package TestApp::Controller::Simple;
use strict;
use warnings;

use base 'Catalyst::Controller::RequestToken';

sub form : Local {
    my ( $self, $c ) = @_;

    my $html = <<HTML;
<html>
<head></head>
<body>
FORM
<form action="confirm" method="post">
<input type="submit" name="submit" value="submit"/>
</form>
</body>
</html>
HTML

$c->response->body($html);
}

sub confirm : Local : CreateToken {
    my ( $self, $c ) = @_;
    
    my $html = <<HTML;
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

my $token = $c->req->param('_token');
$html =~ s/TOKEN/$token/g;

$c->response->body($html);
}

sub complete : Local : ValidateToken {
    my ( $self, $c ) = @_;
    
    my $success = <<HTML;
<html><body>SUCCESS</body></html>
HTML
    
    my $fail = <<HTML;
<html><body>FAIL</body></html>
HTML

    my $html = $self->validate_token ? $success : $fail;
$c->response->body($html);
}

1;
