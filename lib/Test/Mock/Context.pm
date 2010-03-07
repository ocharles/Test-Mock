package Test::Mock::Context;
use Moose;
use namespace::autoclean;

sub mock
{
}

sub satisfied
{
    return 1;
}

__PACKAGE__->meta->make_immutable;
