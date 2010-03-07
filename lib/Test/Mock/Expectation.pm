package Test::Mock::Expectation;
use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw( ArrayRef Object Str );
use Test::Mock::Types qw( Invocation );
use namespace::autoclean;

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
    traits    => [ 'Array' ],
    predicate => 'has_parameter_expectaions'
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
