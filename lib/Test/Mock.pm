package Test::Mock;
# ABSTRACT: A mock object testing framework in order to test behaviour and interactions between classes

use strict;
use warnings;

1;

=head1 SYNOPSIS

    use Test::Mock::Context;

    # In your test:
    my $context = Test::Mock::Context->new;
    my $mock = $context->mock('Class::Name');

    # Declare some expectations:
    $context->expect($mock, 'method_name')

    # Run some code on the mocks
    $mock->method_name;

    # Verify that your expectations were met:
    $context->satisfied; # True

=head1 DESCRIPTION

Mocking frameworks have existed for a while, and can be a great help
when you need to test the interaction between objects. Test::Mock
takes a JMock style approach to mocking -- you declare expectations,
then run your code, and finally verify that your expectatiotns were
met.

=head1 See Also

There are a few other modules that address the problem of mocking, and
you may find them better for your problem domain:

=over 4

=item L<Test::Mock::Class>

A L<Moose> based mocking solution, with some basic support for mocking
expectations.

=item L<Test::MockClass>

A simple implementation of mocking

=item L<Test::MockObject>

Goes as far as creating stub objects

=back

This project was motivated by the JMock framework.

=cut
