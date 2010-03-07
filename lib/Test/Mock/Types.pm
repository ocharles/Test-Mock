package Test::Mock::Types;
use MooseX::Types -declare => [qw( Expectation Invocation )];

class_type Expectation, { class => 'Test::Mock::Expectation' };
class_type Invocation, { class => 'Test::Mock::Invocation' };

1;
