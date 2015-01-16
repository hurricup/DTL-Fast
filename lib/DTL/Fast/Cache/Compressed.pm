package DTL::Fast::Cache::Compressed;
use strict; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Cache::Serialized';
use Carp;

our %CACHE;

#@Override
sub new
{
    my $proto = shift;
    require Compress::Zlib;

    return $proto->SUPER::new(@_);
}

#@Override
sub read_serialized_data
{
    my $self = shift;

    return 
        $self->decompress(
            $self->read_compressed_data(
                shift
            )
        );
}

#@Override
sub write_serialized_data
{
    my $self = shift;

    $self->write_compressed_data(
        shift,
        $self->compress(
            shift
        )
    ) if defined $_[1]; # don't store undef values
}


sub read_compressed_data{ return shift->SUPER::read_serialized_data(@_) };

sub write_compressed_data{ return shift->SUPER::write_serialized_data(@_) };

sub compress
{
    shift;
    return if not defined $_[0];
    return Compress::Zlib::memGzip(shift);
}

sub decompress
{
    shift;
    return if not defined $_[0];
    return Compress::Zlib::memGunzip(shift);
}



1;