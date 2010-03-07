package Test::Mock::Context;
use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw( ArrayRef Object Str );
use MooseX::Types::Structured qw( Tuple );
use Test::Mock::Types qw( Expectation Invocation );
use namespace::autoclean;

use List::MoreUtils qw( zip );
use Moose::Meta::Class;
use Class::MOP::Method;
use Test::Mock::Expectation;
use Test::Mock::Invocation;

has 'expecations' => (
    is      => 'ro',
    isa     => ArrayRef[Expectation],
    traits  => [ 'Array' ],
    default => sub { [] },
    handles => {
        _add_expecatation => 'push'
    }
);

has 'run_log' => (
    is      => 'ro',
    isa     => ArrayRef[Invocation],
    traits  => [ 'Array' ],
    default => sub { [] },
    handles => {
        _add_invocation => 'push'
    }
);

method mock (Str $class)
{
    my $package = $class . '::Mock';
    my $mock = Moose::Meta::Class->create(
        $package => (
            superclasses => [ $class, $class->meta->superclasses ],
            methods      => {
                map {
                    my $method = $_;
                    $method => sub {
                        my $mock = shift;
                        $self->invoke($mock, $method);
                    }
                } grep { $self->should_mock($_) } $class->meta->get_all_method_names
            }
        ));

    return $mock->new_object;
}

method invoke (Object $receiver, Str $method)
{
    $self->_add_invocation(
        Test::Mock::Invocation->new(
            receiver => $receiver,
            method   => $method
        ));
}

method should_mock (Str $method_name)
{
    return !($method_name =~ /can|DEMOLISHALL|DESTROY|DOES|does|meta|isa|VERSION/);
}

method expect (Object $mock, Str $method_name)
{
    $self->_add_expecatation(
        Test::Mock::Expectation->new(
            receiver => $mock,
            method   => $method_name
        ));
}

method satisfied
{
    my @expect = @{ $self->expecations };
    my @actual = @{ $self->run_log };

    while (@expect && @actual)
    {
        my $expected = shift @expect;
        my $actual   = shift @actual;

        if ($expected->receiver == $actual->receiver && $expected->method ne $actual->method) {
            return;
        }
    }

    return if @expect != @actual;
    return 1;
}

__PACKAGE__->meta->make_immutable;
