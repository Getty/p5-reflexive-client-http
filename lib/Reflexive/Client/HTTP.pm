package Reflexive::Client::HTTP;
# ABSTRACT: A Reflex HTTP Client

our $VERSION ||= '0.000';

use Moose;
extends 'Reflex::Base';

use POE::Component::Client::HTTP;
use Reflex::POE::Event;
use Reflexive::Client::HTTP::ResponseEvent;

use Carp qw( croak );
use Scalar::Util qw( refaddr );

=attr agent

The useragent to use for the HTTP client. Defaults to the package name and the
current version of it.

=cut

has agent => (
	is      => 'ro',
	isa     => 'Str',
	default => sub { (ref $_[0] ? ref $_[0] : $_[0]).'/'.$VERSION },
);

=attr from
=cut

has from => (
	is        => 'ro',
	isa       => 'Str',
	predicate => 'has_from',
);

=attr protocol
=cut

has protocol => (
	is        => 'ro',
	isa       => 'Str',
	predicate => 'has_protocol',
);

=attr timeout
=cut

has timeout => (
	is        => 'ro',
	isa       => 'Str',
	predicate => 'has_timeout',
);

=attr max_size
=cut

has max_size => (
	is        => 'ro',
	isa       => 'Int',
	predicate => 'has_max_size',
);

=attr follow_redirects
=cut

has follow_redirects => (
	is        => 'ro',
	isa       => 'Int',
	predicate => 'has_follow_redirects',
);

=attr proxy
=cut

has proxy => (
	is        => 'ro',
	isa       => 'Str',
	predicate => 'has_proxy',
);

=attr no_proxy
=cut

has no_proxy => (
	is        => 'ro',
	isa       => 'ArrayRef[Str]',
	predicate => 'has_no_proxy',
);

=attr bind_addr
=cut

has bind_addr => (
	is        => 'ro',
	isa       => 'Str',
	predicate => 'has_bind_addr',
);

=attr alias

The internal POE alias. It is actually never required to set this attribute to
a different value. Or in other words: NO NO TOUCHY!

=cut

my $alias_id = 0;

has alias => (
	is      => 'ro',
	isa     => 'Str',
	default => sub { 'reflexive_client_http_alias_'.(++$alias_id) },
);

sub BUILD {
	my ($self) = @_;

	# Start an HTTP user-agent when the object is created.

	POE::Component::Client::HTTP->spawn(
		Agent => $self->agent,
		$self->has_from ? ( From => $self->from ) : (),
		$self->has_protocol ? ( Protocol => $self->protocol ) : (),
		$self->has_max_size ? ( Protocol => $self->protocol ) : (),
		$self->has_timeout ? ( Protocol => $self->protocol ) : (),
		$self->has_follow_redirects ? ( Protocol => $self->protocol ) : (),
		$self->has_proxy ? ( Protocol => $self->protocol ) : (),
		$self->has_no_proxy ? ( NoProxy => $self->no_proxy ) : (),
		$self->has_bind_addr ? ( BindAddr => $self->bind_addr ) : (),

		Alias => $self->alias,
	);
}

sub DESTRUCT {
	my ($self) = @_;

	# Shut down POE::Component::Client::HTTP when this object is
	# destroyed.

	POE::Kernel->post(ua => $self->alias());
}

sub request {
	# Make a request.

	my ($self, $http_request, @args) = @_;

	# There is no guarantee that the caller of request() is running in
	# the same POE session as this Reflexive::Client::HTTP object.
	#
	# Reflex::Base's run_within_session() method makes sure that the
	# right session is active when interacting with POE code.  This
	# ensures that POE-based responses are properly routed.

	# The Reflex::POE::Event object created here is an event for POE's
	# purpose, but it includes Reflex magic to route responses back to
	# the correct Reflex object.

	$self->run_within_session(
		sub {
			POE::Kernel->post(
				$self->alias(),
				'request',
				Reflex::POE::Event->new(
					object => $self,
					method => 'internal_http_response',
					context => { args => [@args] },
				),
				$http_request,
			);
		}
	);
}

sub internal_http_response {
	my ($self, $args) = @_;

	my @request_args = @{ $args->{context}->{args} };

	my ($request, $response) = @{ $args->{response} };

	if (defined $request_args[0] && ref $request_args[0] eq 'CODE') {
		my $callback = shift @request_args;
		for ($response->[0]) {
			$callback->(@request_args);
		}
	} else {
		$self->emit(
			-name    => 'response',

			-type    => 'Reflexive::Client::HTTP::ResponseEvent',
			request  => $request->[0],
			response => $response->[0],

			@request_args ? ( args => [@request_args] ) : (),
		);
	}
}

1;

=head1 THANKS

Big thanks to B<dngor> for helping me through the process to understand
L<Reflex> enough for making this. Most of this is based on his code.

=head1 SUPPORT

IRC

  Join #reflex on irc.perl.org. Highlight Getty or dngor for fast reaction :).

Repository

  http://github.com/Getty/p5-reflexive-client-http
  Pull request and additional contributors are welcome
 
Issue Tracker

  http://github.com/Getty/p5-reflexive-client-http/issues


