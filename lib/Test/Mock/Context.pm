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
                        $self->invoke($mock, $method, @_);
                    }
                } grep { $self->should_mock($_) } $class->meta->get_all_method_names
            }
        ));

    return $mock->new_object;
}

method invoke (Object $receiver, Str $method, @parameters)
{
    $self->_add_invocation(
        Test::Mock::Invocation->new(
            receiver   => $receiver,
            method     => $method,
            parameters => \@parameters
        ));
}

method should_mock (Str $method_name)
{
    return !($method_name =~ /can|DEMOLISHALL|DESTROY|DOES|does|meta|isa|VERSION/);
}

method expect (Object $mock, Str $method_name)
{
    my $expectation = Test::Mock::Expectation->new(
        receiver => $mock,
        method   => $method_name
    );
    $self->_add_expecatation($expectation);

    return $expectation;
}

method satisfied
{
    my @expect = @{ $self->expecations };
    my @actual = @{ $self->run_log };

    while (@expect && @actual)
    {
        my $expected = shift @expect;
        my $actual   = shift @actual;

        $expected->is_satisfied_by($actual)
            or return 0;
    }

    return 0 if @expect != @actual;
    return 1;
}

__PACKAGE__->meta->make_immutable;
