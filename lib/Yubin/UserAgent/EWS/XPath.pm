package Yubin::UserAgent::EWS::XPath;

use Moose::Role;

use XML::LibXML;
use XML::Bare qw/xmlin/;
use Data::Dump qw/dump/;

has 'xpc' => ( is => 'ro', default => sub {
		  my $xpc = XML::LibXML::XPathContext->new;
		  $xpc->registerNs('t', 'http://schemas.microsoft.com/exchange/services/2006/types');
		  $xpc->registerNs('m', 'http://schemas.microsoft.com/exchange/services/2006/messages');
		  return $xpc;
	      } );

sub xpath {
    my ($self, $xpath, $xml) = @_;
    $xml ||= $self->xml;
    my $dom = XML::LibXML->load_xml(string => $xml);
    
    return map {
	xmlin("$_")
    } $self->xpc->findnodes($xpath, $dom)
}

sub find {
    my ($self, $xpath, $xml) = @_;
    $xml ||= $self->xml;
    my $dom = XML::LibXML->load_xml(string => $xml);
    return ($self->xpc->find($xpath, $dom)->to_literal)
}

1;
