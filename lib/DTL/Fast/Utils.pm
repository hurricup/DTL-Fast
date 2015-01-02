package DTL::Fast::Utils;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'Exporter';

our @EXPORT_OK;

push @EXPORT_OK, 'is_object';
sub is_object
{
    my $ref = shift;
    return (
        ref $ref
        and UNIVERSAL::can($ref, 'can')
    );
}

push @EXPORT_OK, 'has_method';
sub has_method
{
    my $ref = shift;
    my $method = shift;
    
    return (
        is_object($ref)
        and $ref->can($method)
    );
}

1;