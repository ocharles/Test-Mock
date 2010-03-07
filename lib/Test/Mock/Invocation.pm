package Test::Mock::Invocation;
# ABSTRACT: Represents an actual invocation of a method
use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw( ArrayRef Object Str );
use namespace::autoclean;

has 'receiver' => (
    is       => 'ro',
    isa      => Object,
    required => 1
);

has 'method' => (
    is       => 'ro',
    isa      => Str,
    required => 1
);

has 'parameters' => (
    is        => 'ro',
    isa       => ArrayRef,
    predicate => 'has_parameters'
);

__PACKAGE__->meta->make_immutable;

=head1 ATTRIBUTES

=head2 receiver

B<Required>. The object that the method was invoked on.

=head2 method

B<Required>. The name of the method invoked.

=head2 parameters

All the parameters passed to the method (except $self).

=cut
