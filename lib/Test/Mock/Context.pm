package Test::Mock::Context;
use Moose;
use MooseX::Method::Signatures;
use namespace::autoclean;

use Moose::Meta::Class;
use Class::MOP::Method;

method mock (Str $class)
{
    my $package = $class . '::Mock';
    my $mock = Moose::Meta::Class->create(
        $package => (
            superclasses => [ $class, $class->meta->superclasses ],
            methods      => {
                map {
                    $_ => sub { }
                } $class->meta->get_all_method_names
            }
        ));

    return $mock->new_object;
}


sub expect
{

}

sub satisfied
{
    return 1;
}

__PACKAGE__->meta->make_immutable;
