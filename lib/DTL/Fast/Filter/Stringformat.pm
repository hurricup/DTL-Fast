package DTL::Fast::Filter::Stringformat;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Filter';
use Carp;

$DTL::Fast::FILTER_HANDLERS{'stringformat'} = __PACKAGE__;

use DTL::Fast::Variable;

#@Override
sub parse_parameters
{
    my $self = shift;
    croak "No format string specified"
        if not scalar @{$self->{'parameter'}};
    $self->{'format'} = $self->{'parameter'}->[0];
    return $self;
}

#@Override
sub filter
{
    my $self = shift;  # self
    shift;  # filter_manager
    my $value = shift;
    my $context = shift;
    
    my $format = $self->{'format'}->render($context);
    
    return sprintf '%'.$format, $value;
}

1;