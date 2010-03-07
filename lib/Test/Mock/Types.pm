package Test::Mock::Types;
use MooseX::Types -declare => [qw( Expectation )];

class_type Expectation, { class => 'Test::Mock::Expectation' };

1;
