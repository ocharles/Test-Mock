package Test::Mock::Expectation;
use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw( Object Str );
use Test::Mock::Types qw( Invocation );
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

method is_satisfied_by (Invocation $invocation)
{
    return $self->receiver == $invocation->receiver &&
        $self->method eq $invocation->method;
}

__PACKAGE__->meta->make_immutable;
