package Reflexive::Client::HTTP::ResponseEvent;
# ABSTRACT: A response event of a call with Reflexive::Client::HTTP

use Moose;
extends 'Reflex::Event';

use HTTP::Request;
use HTTP::Response;

=attr

L<HTTP::Request> object of the event.

=cut

has request => (
	is       => 'ro',
	isa      => 'HTTP::Request',
	required => 1,
);

=attr

L<HTTP::Response> object of the given L</request>.

=cut

has response => (
	is       => 'ro',
	isa      => 'HTTP::Response',
	required => 1,
);

=attr args

If arguments are given to the L<Reflexive::Client::HTTP/request> call, then
you can find them in this attribute. If no arguments are given L</has_args>
gives back false and the attribute will be undefined and no ArrayRef.

=cut

has args => (
	is       => 'ro',
	isa      => 'ArrayRef',
	predicate => 'has_args',
);

__PACKAGE__->make_event_cloner;
__PACKAGE__->meta->make_immutable;

1;