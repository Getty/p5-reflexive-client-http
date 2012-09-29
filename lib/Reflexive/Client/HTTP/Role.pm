package Reflexive::Client::HTTP::Role;
# ABSTRACT: A role for automatically getting a watched Reflexive::Client::HTTP

use Moose::Role;

with 'Reflex::Role::Reactive';

use Reflex::POE::Wheel::Run;
use Reflex::Trait::Watched qw(watches);
use Reflexive::Client::HTTP;

=head1 SYNOPSIS

  package MyServiceClient;

  use Moose;
  extends 'Reflex::Base';

  with 'Reflexive::Client::HTTP::Role';

  sub on_http_response {
    my ( $self, $response_event ) = @_;
  }

=head1 DESCRIPTION

=attr http

This watched attribute containts the L<Reflexive::Client::HTTP>. It handles
L</http_request> which triggers L<Reflexive::Client::HTTP/request>.

=cut

watches http => (
	is => 'ro',
	isa => 'Reflexive::Client::HTTP',
	lazy_build => 1,
	handles => {
		http_request => 'request',
	},
);

sub _build_http { Reflexive::Client::HTTP->new(shift->http_options) }

=attr http_options

This HashRef is used for constructing the L<Reflexive::Client::HTTP> in
L</http>.

=cut

has http_options => (
	is => 'ro',
	isa => 'HashRef',
	default => sub {{}},
);

=method http_request

See L<Reflexive::Client::HTTP/request>.

=cut

1;