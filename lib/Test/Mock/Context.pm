package Test::Mock::Context;
use Moose;
use MooseX::Method::Signatures;
use namespace::autoclean;

method mock (Str $class)
{
    return $class->new;
}


sub expect
{

}

sub satisfied
{
    return 1;
}

__PACKAGE__->meta->make_immutable;
