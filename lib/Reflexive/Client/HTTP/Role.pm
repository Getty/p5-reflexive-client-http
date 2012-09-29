package Reflexive::Client::HTTP::Role;
# ABSTRACT: A role for automatically getting a watched Reflexive::Client::HTTP

use Moose::Role;

with 'Reflex::Role::Reactive';

use Reflex::POE::Wheel::Run;
use Reflex::Trait::Watched qw(watches);
use Reflexive::Client::HTTP;

=head1 SYNOPSIS

  {
    package MySampleClient;

    use Moose;
    extends 'Reflex::Base';

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

=head1 DESCRIPTION

If you attach this role, your L<Moose> class gets an additional attribute
C<http> which contains a L<Reflexive::Client::HTTP>. This allows you to add a
simple C<on_http_response> method, which gets the
L<Reflexive::Client::HTTP::ResponseEvent> on the success of a previous
executed call to L</http_request>.

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