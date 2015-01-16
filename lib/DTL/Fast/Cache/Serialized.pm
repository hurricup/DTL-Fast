package DTL::Fast::Cache::Serialized;
use strict; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Cache::Runtime';
use Carp;
use Storable;

#@Override
sub read_data
{
    my $self = shift;
    
    return 
        $self->deserialize(
            $self->read_serialized_data(
                shift
            )
        );
}

#@Override
sub write_data
{
    my $self = shift;
    
    $self->write_serialized_data(
        shift,
        $self->serialize(
            shift
        )
    ) if defined $_[1]; # don't store undef values
}

sub read_serialized_data{ return shift->SUPER::read_data(@_) };

sub write_serialized_data{ return shift->SUPER::write_data(@_) };

sub serialize
{
    shift;
    return if not defined $_[0];
    return Storable::freeze(shift);
}

sub deserialize
{
    shift;
    return if not defined $_[0];
    return Storable::thaw(shift);
}

1;