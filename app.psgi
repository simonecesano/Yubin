use strict;
use warnings;

use FindBin;
use Plack::Builder;
use Plack::App::File;
use Plack::App::Proxy;

use Mojo::Server::PSGI;

builder {
    mount "/" => builder {
    	my $server = Mojo::Server::PSGI->new;
    	$server->load_app('./yubin.pl');
    	$server->to_psgi_app;
    };
};

