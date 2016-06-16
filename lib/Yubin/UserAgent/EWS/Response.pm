package Yubin::UserAgent::EWS::Response;

use Moose;
use HTTP::Response;
use XML::Bare qw/xmlin/;
use JSON;

use Data::Dump qw/dump/;

with qw/Yubin::UserAgent::EWS::XPath/;

has response => (
		 is => 'ro',
		 isa => 'HTTP::Response',
		 handles => [qw/is_success/]
		);


sub xml {
    my $self = shift;
    if ($self->response->is_success) {
	return $self->response->decoded_content;
    } 
}

sub json {
    my $self = shift;
    if ($self->response->is_success) {
	return xmlin($self->response->decoded_content);
    } else {
	return {};
    }
}


1;
