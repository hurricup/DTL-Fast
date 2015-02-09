package DTL::Fast::Filter::Getdigit;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Filter';

$DTL::Fast::FILTER_HANDLERS{'get_digit'} = __PACKAGE__;

#@Override
sub parse_parameters
{
    my $self = shift;
    die "No digit number specified"
        if not scalar @{$self->{'parameter'}};
    $self->{'digit'} = $self->{'parameter'}->[0];
    return $self;
}

#@Override
sub filter
{
    my $self = shift;  # self
    shift;  # filter_manager
    my $value = shift;  # value
    my $context = shift;    #context
    
    my $digit = $self->{'digit'}->render($context);
    if(
        $value =~ /^\d+$/ 
        and $digit =~ /^\d+$/ 
        and $digit > 0
    )
    {
        if( length $value >= $digit )
        {
            $value = substr $value, -$digit, 1;
        }
        else
        {
            $value = '';
        }
    }
    
    return $value;
}

1;