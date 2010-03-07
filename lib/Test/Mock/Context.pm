package Test::Mock::Context;
# ABSTRACT: The mocking context which oversees the mocking process
use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw( ArrayRef Object Str );
use MooseX::Types::Structured qw( Map Tuple );
use Test::Mock::Types qw( Expectation Invocation );
use namespace::autoclean;

use Carp;
use List::MoreUtils qw( zip );
use Moose::Meta::Class;
use Class::MOP::Method;
use Test::Mock::Expectation;
use Test::Mock::Invocation;

has 'expectations' => (
    is      => 'ro',
    isa     => Map[Object, ArrayRef[Expectation]],
    default => sub { {} },
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
    my @expectations = @{ $self->expectations->{$receiver} || [] };

    $self->_add_invocation(
        Test::Mock::Invocation->new(
            receiver   => $receiver,
            method     => $method,
            parameters => \@parameters
        ));

    if (@expectations == 0) {
        croak "$method was invoked but not expected";
    }
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
    $self->expectations->{$mock} ||= [];
    push @{ $self->expectations->{$mock} }, $expectation;

    return $expectation;
}

method satisfied
{
    for my $actual (@{ $self->run_log }) {
        my $expected = shift @{ $self->expectations->{ $actual->receiver } };
        return 0 if !defined $expected;

        $expected->is_satisfied_by($actual)
            or return 0;
    }

    my @remaining_expectations = map { @{$_} } values %{ $self->expectations };
    return @remaining_expectations == 0;
}

__PACKAGE__->meta->make_immutable;

=head1 METHODS

=head2 mock(Str $class) : Object

Mock the class named C<$class>. The mock object will be C<ISA $class>,
and will have all the methods that C<$class> does (but obviously
invoking them doesn't run them).

=head2 expect(Object $receiver, Str $method_name) : Test::Mock::Expectation

Register an expected method call of C<$method_name> on
C<$receiver>. This will return a C<Test::Mock::Expectation>, which you
can specialize further with chaining if you need to specify further
constraints.

=head2 satisfied : Bool

Check through the list of expectations and invocations, and make sure
that they are consistent. That is, every invocation satisfies some
sort of expectation in the correct order.

=cut
