package Test::Mock::Expectation;
# ABSTRACT: Represents an expected invocation of a method
use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw( ArrayRef Object Str );
use Test::Mock::Types qw( Invocation );
use namespace::autoclean;

use Moose::Meta::Attribute::Custom::Trait::Chained;

use Data::Compare;

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
    is        => 'rw',
    isa       => ArrayRef,
    traits    => [ 'Array', 'Chained' ],
    predicate => 'has_parameter_expectaions'
);

has 'return' => (
    is     => 'rw',
    traits => [ 'Chained' ]
);

method is_satisfied_by (Invocation $invocation)
{
    return 0 if $self->receiver != $invocation->receiver;
    return 0 if $self->method ne $invocation->method;

    if ($self->has_parameter_expectaions) {
        return 0 unless $invocation->has_parameters;

        my @expected = @{ $self->parameters };
        my @actual   = @{ $invocation->parameters };
        return 0 unless @expected == @actual;

        while(@expected && @actual)
        {
            my $exp = shift @expected;
            my $act = shift @actual;

            return unless Compare($exp, $act);
        }
    }

    return 1;
}

__PACKAGE__->meta->make_immutable;

=head1 ATTRIBUTES

=head1 receiver : Object

B<Required>. The object that a method should be invoked on.

=head1 method : Str

B<Required>. The name of the method to be invoked.

=head1 parameters : ArrayRef

An array reference of parameter expectations. At the moment this is an
array reference of how C<@_> should look when the method is
invoked. In the future, there will be parameter expectation objects
which can work over multiple paramaters, test out of order (eg, hash
maps), test patterns, etc.

=head1 return : Any

Data to return when this expectation is called.

=cut
