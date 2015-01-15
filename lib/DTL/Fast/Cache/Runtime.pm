package DTL::Fast::Cache::Runtime;
use strict; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Cache';
use Carp;

# Runtime cache for compiled templates

our %CACHE;

#@Override
sub read_data
{
    shift;
    my $key = shift;
    return exists $CACHE{$key} ? $CACHE{$key}: undef;
}

#@Override
sub write_data
{
    shift;
    my $key = shift;
    my $data = shift;
    $CACHE{$key} = $data;
}

#@Override
sub clear{%CACHE = ();}

1;