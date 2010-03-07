package Test::Mock::Invocation;
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
