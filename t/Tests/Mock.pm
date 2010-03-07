package Tests::Mock;
use strict;
use warnings;
use base 'Test::Class';
use Test::Class::Most;

use aliased 'Test::Mock::Context' => 'MockContext';

{
    package ToMock;
    use Moose;

    sub explode
    {
    }
}

sub startup : Tests(startup => 1)
{
    my $test = shift;
    $test->{context} = MockContext->new;
    $test->{mock}    = $test->{context}->mock('ToMock');
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

1;
