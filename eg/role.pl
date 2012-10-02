#!/usr/bin/env perl

use warnings;
use strict;
use lib qw(../lib);

{
	package MySampleClient;

	use Moose;
	with 'Reflexive::Client::HTTP::Role';

	sub on_http_response {
		my ( $self, $response_event ) = @_;
		my $http_response = $response_event->response;
		my ( $who ) = @{$response_event->args};
		print $who." got status ".$http_response->code."\n";
	}

	sub request {
		my ( $self, $who ) = @_;
		$self->http_request( HTTP::Request->new( GET => 'http://www.duckduckgo.com/' ), $who );
	}
}

my $msc = MySampleClient->new;
$msc->request('peter');
$msc->request('paul');
$msc->request('marry');

Reflex->run_all();

exit;

