package DTL::Fast::Cache::Serialized;
use strict; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Cache';
use Carp;

our %CACHE;

#@Override
sub new
{
    my $proto = shift;
    require Compress::Zlib;
    require Storable;

    return $proto->SUPER::new(@_);
}

#@Override
sub read_data
{
    my $self = shift;
    my $key = shift;
    my $result;
    
    eval
    {
        $result = $self->read_data_serialized($key);
        $result = Storable::thaw(
            Compress::Zlib::memGunzip( $result )
        ) if defined $result;
    };
    croak $@ if $@;
    return $result;
}

#@Override
sub write_data
{
    my $self = shift;
    my $key = shift;
    my $data = shift;

    $self->write_data_serialized(
        $key
        , Compress::Zlib::memGzip(
            Storable::freeze($data)
        )
    );
}

#@Override
sub clear{%CACHE = ();}

sub read_data_serialized
{
    shift;
    my $key = shift;
    return exists $CACHE{$key} ? $CACHE{$key}: undef;
}

sub write_data_serialized
{
    shift;
    my $key = shift;
    my $data = shift;
    $CACHE{$key} = $data;
}


1;