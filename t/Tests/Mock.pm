package Tests::Mock;
use strict;
use warnings;
use base 'Test::Class';
use Test::Class::Most;

use aliased 'Test::Mock::Context' => 'MockContext';

{
    package ToMock;
}

sub replay_nothing : Test
{
    my $context = MockContext->new;
    my $mock = $context->mock('ToMock');

    ok $context->satisfied;
}

1;
