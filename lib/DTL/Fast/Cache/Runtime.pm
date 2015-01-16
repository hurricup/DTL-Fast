package DTL::Fast::Cache::Runtime;
use strict; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Cache';
use Carp;

# Runtime cache for compiled templates

#@Override
sub new
{
    my $proto = shift;
    my %kwargs = @_;
    
    $kwargs{'cache'} = {};

    return $proto->SUPER::new(%kwargs);
}

sub read_data
{
    my $self = shift;
    my $key = shift;
    return if not defined $key;
    return exists $self->{'cache'}->{$key} ? $self->{'cache'}->{$key}: undef;
}


sub write_data
{
    my $self = shift;
    my $key = shift;
    my $data = shift;
    return if not defined $key;
    return if not defined $data;
    $self->{'cache'}->{$key} = $data;
}

#@Override
sub clear{shift->{'cache'} = {};}

1;