package Tests::Mock;
use strict;
use warnings;
use base 'Test::Class';
use Test::Class::Most;
use Test::Moose;

use aliased 'Test::Mock::Context' => 'MockContext';

{
    package ToMock;
    use Moose;

    sub explode { }
    sub defuse  { }
    sub tick    { }
}

{
    package ToMock::Role;
    use Moose::Role;

    sub dance { }
}

sub startup : Tests(setup => 1)
{
    my $test = shift;
    $test->{context} = MockContext->new;
    $test->{mock}    = $test->{context}->mock('ToMock');
    $test->{role}    = $test->{context}->mock('ToMock::Role');
}

sub replay_nothing : Test
{
    my $test = shift;
    ok $test->{context}->satisfied;
}

sub single_expectation : Test
{
    my $test = shift;
    my $context = $test->{context};
    my $mock = $test->{mock};

    $context->expect($mock, 'explode');

    $mock->explode;

    ok $context->satisfied;
}

sub mocks_mock_class : Test(2)
{
    my $test = shift;
    my $context = $test->{context};
    my $mock = $test->{mock};

    isnt ref $mock, 'ToMock';
    ok $mock->isa('ToMock');
}

sub call_with_no_expectation : Test(2)
{
    my $test = shift;
    my $context = $test->{context};
    my $mock = $test->{mock};

    dies_ok { $mock->explode };

    ok !$context->satisfied;
}

sub expectation_with_no_call : Test
{
    my $test = shift;
    my $context = $test->{context};
    my $mock = $test->{mock};

    $context->expect($mock, 'explode');

    ok !$context->satisfied;
}

sub multiple_expecations : Test
{
    my $test = shift;
    my $context = $test->{context};
    my $mock = $test->{mock};

    $context->expect($mock, 'tick');
    $context->expect($mock, 'defuse');
    $context->expect($mock, 'explode');

    $mock->tick;
    $mock->defuse;
    $mock->explode;

    ok $context->satisfied;
}

sub expectation_order : Test(2)
{
    my $test = shift;
    my $context = $test->{context};
    my $mock = $test->{mock};

    $context->expect($mock, 'tick');
    $context->expect($mock, 'defuse');
    $context->expect($mock, 'explode');

    dies_ok {
        $mock->explode;
        $mock->tick;
        $mock->defuse;
    }, qr/Expected tick, actually got explode/;

    ok !$context->satisfied;
}

sub verifies_parameters : Test
{
    my $test = shift;
    my $context = $test->{context};
    my $mock = $test->{mock};

    $context->expect($mock, 'tick')->parameters([ 5 ]);

    $mock->tick(5);

    ok $context->satisfied;
}

sub verifies_invalid_parameters : Test(2)
{
    my $test = shift;
    my $context = $test->{context};
    my $mock = $test->{mock};

    $context->expect($mock, 'tick')->parameters([ 5 ]);

    dies_ok { $mock->tick(10) };

    ok !$context->satisfied;
}

sub can_return_data : Test(2)
{
    my $test = shift;
    my $context = $test->{context};
    my $mock = $test->{mock};

    $context->expect($mock, 'defuse')->return('red wire');

    my $wire_cut = $mock->defuse();

    ok $context->satisfied;
    is $wire_cut, 'red wire';
}

sub can_mock_roles : Test(2)
{
    my $test = shift;
    my $context = $test->{context};
    my $mock = $test->{role};

    $context->expect($mock, 'dance');

    $mock->dance;

    does_ok $mock, 'ToMock::Role';
    ok $context->satisfied;
}

1;
