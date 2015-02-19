package DTL::Fast::Filter::Join;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Filter';

$DTL::Fast::FILTER_HANDLERS{'join'} = __PACKAGE__;

#@Override
sub parse_parameters
{
    my( $self ) = @_;

    die "No separator passed to the filter ".__PACKAGE__
        if(
            ref $self->{'parameter'} ne 'ARRAY'
            or not scalar @{$self->{'parameter'}}
        );
        
    $self->{'sep'} = $self->{'parameter'}->[0];
        
    return $self;    
}

#@Override
sub filter
{
    my( $self, $filter_manager, $value, $context ) = @_;
    
    my $value_type = ref $value;
    my $result = undef;
    my $separator = $self->{'sep'}->render($context, 1);
    
    my @source = ();
    if( $value_type eq 'HASH' )
    {
        @source = (%$value);
    }
    elsif( $value_type eq 'ARRAY' )
    {
        @source = @$value;
    }
    else
    {
        die sprintf( "Unable to apply filter %s to the %s value"
            , __PACKAGE__
            , $value_type || 'SCALAR'            
        );
    }    
    
    if( $filter_manager->{'safeseq'} )
    {
        DTL::Fast::html_protect($separator) 
            if not $context->get('_dtl_safe');
            
        $filter_manager->{'safe'} = 1;
    }
    
    return join $separator, @source;
}

1;