package DTL::Fast::Template::Filter::Join;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter';
use Carp qw(confess);

$DTL::Fast::Template::FILTER_HANDLERS{'join'} = __PACKAGE__;

use DTL::Fast::Template::Variable;

#@Override
sub parse_parameters
{
    my $self = shift;

    confess "No separator passed to the filter ".__PACKAGE__
        if(
            ref $self->{'parameter'} ne 'ARRAY'
            or not scalar @{$self->{'parameter'}}
        );
        
    $self->{'sep'} = DTL::Fast::Template::Variable->new($self->{'parameter'}->[0]);
        
    return $self;    
}

#@Override
sub filter
{
    my $self = shift;
    my $filter_manager = shift;
    my $value = shift;
    my $context = shift;
    
    my $value_type = ref $value;
    my $result = undef;
    my $separator = $self->{'sep'}->render($context);
    
    if( $value_type eq 'HASH' )
    {
        $result = join $separator, (%$value);
    }
    elsif( $value_type eq 'ARRAY' )
    {
        $result = join $separator, @$value;
    }
    else
    {
        confess sprintf( "Unable to apply filter %s to the %s value"
            , __PACKAGE__
            , $value_type || 'SCALAR'            
        );
    }    
    return $result;
}

1;