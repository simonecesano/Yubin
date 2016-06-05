package Yubin::UserAgent::EWS;

use Moose;

has [qw/xml/] => ( is => 'rw' );

with qw/Yubin::UserAgent::EWS::XPath 
	Yubin::UserAgent::EWS::Requests 
	Yubin::UserAgent::EWS::LWP/;

use Want;
use XML::Bare qw/xmlin/;

sub request :lvalue {
    my ($self, $template, $data) = @_;
    my $xml = $self->post($self->compile($template, $data))->decoded_content;
    $self->xml($xml);
    if (want('OBJECT')) { return $self }
    return xmlin($xml); 
}


__PACKAGE__->meta->make_immutable;

1;


1;
