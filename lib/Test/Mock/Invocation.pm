package Test::Mock::Invocation;
use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw( Object Str );
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

__PACKAGE__->meta->make_immutable;
