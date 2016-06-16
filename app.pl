#!/usr/bin/env perl
use lib 'lib';
use Mojolicious::Lite;
use Yubin::UserAgent::EWS;
use Data::Dump qw/dump/;

# my ($user, $pass) = map { s/\n//; $_ } (qx/whoami/, qx/security find-generic-password -ws Exchange 2>&1/);
my ($user, $pass) = ('cesansim', 'Local 151');
# Documentation browser under "/perldoc"
plugin 'PODRenderer';
plugin 'ACME';

get '/' => sub {
    my $c = shift;
    if ($c->param('meeting_subject')) {
	my ($user, $pass) = ($c->session('user'), $c->session('password'));
	my $y = Yubin::UserAgent::EWS->new(user => $user, password => $pass, endpoint => 'https://ews.adidas-group.com/ews/exchange.asmx');
	my $res = $y->request('find_meeting', { name => $c->param('meeting_subject') });
	my @ids =
	    map { { id => $_->{'t:ItemId'}->{Id}, subject => $_->{'t:Subject'}, start => $_->{'t:Start'} } }
		  $res->xpath('//*/t:CalendarItem');
	$c->stash(meetings => \@ids);
	$c->render(template => 'meeting/select');
    } else {
	$c->render(template => 'index');
    }
};

my $item = sub {
    my $c = shift;
    my $y = Yubin::UserAgent::EWS->new(user => $user, password => $pass, endpoint => 'https://ews.adidas-group.com/ews/exchange.asmx');
    app->log->info($c->param('item'));
    my $id = $c->param('item');
    my $res = $y->request('get_meeting_responses', { id => $id });
    my $rsp = [ $res->xpath('//*/t:Attendee') ];
    # $c->res->headers->content_type('text/plain');
    $c->render(json => { id => $id, responses => $rsp });
};
get  '/responses/*item' => $item;
post '/responses/' => $item;

get '/login' => sub { shift->render(template => 'login') };

post '/login' => sub {
    my $c = shift;
    my $y = Yubin::UserAgent::EWS->new(user => $c->param('user'), password => $c->param('password'), endpoint => 'https://ews.adidas-group.com/ews/exchange.asmx');

    my $res = $y->request('resolve_name', { name => $c->param('user') });
    if ($res->is_success) {
	$c->session({ user => $c->param('user') });
	$c->session({ password => $c->param('password') });
	$c->redirect_to('/');
    } else {
	$c->render(text => 'not logged in')
    }	
};


get '/logout' => sub {
    my $c = shift;
    $c->session({ password => undef });
    $c->render(text => '/login');
};


get '/u/:user/prefs' => sub {
    my $c = shift;
    $c->render(text => '/u/:user/prefs');
};

app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'Welcome';
<h1>Welcome to the Mojolicious real-time web framework!</h1>
To learn more, you can browse through the documentation
<%= link_to 'here' => '/perldoc' %>.

