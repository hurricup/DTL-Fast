package DTL::Fast::Filter;
use strict; use utf8; use warnings FATAL => 'all'; 

use DTL::Fast::Template;

sub new
{
    my( $proto, $parameter, %kwargs)  = @_;
    
    $kwargs{'parameter'} = $parameter // [];
    
    die "Parameter must be an ARRAY reference" 
        if ref $kwargs{'parameter'} ne 'ARRAY';
    
    my $self = bless {%kwargs}, $proto;
    
    return $self->parse_parameters();
}

sub parse_parameters{return shift;}

sub filter
{
    die "This is abstract method and it must be overrided";
}

1;
