package DTL::Fast::Template::Filter::Join;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter';
use Carp qw(confess);

$DTL::Fast::Template::FILTER_HANDLERS{'join'} = __PACKAGE__;

use DTL::Fast::Context;
use DTL::Fast::Template::Variable;

sub new
{
    my $proto = shift;
    my $arguments = shift;  # this is a single argument. Arrayref with filter arguments splitted by /:/
    
    confess "No separator passed to the filter ".__PACKAGE__
        if(
            ref $arguments ne 'ARRAY'
            or not scalar @$arguments
        );

    # parent class just blesses passed hash with proto. Nothing more. Use it
    # for future compatibility
    return $proto->SUPER::new(
    {
        'sep' => DTL::Fast::Template::Variable->new($arguments->[0])
    });    
}

# filtering function
sub filter
{
    my $self = shift;
    my $value = shift;
    my $context = shift // DTL::Fast::Context->new();
    
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