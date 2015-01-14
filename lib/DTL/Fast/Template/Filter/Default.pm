package DTL::Fast::Template::Filter::Default;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter';
use Carp;

$DTL::Fast::Template::FILTER_HANDLERS{'default'} = __PACKAGE__;

#@Override
sub parse_parameters
{
    my $self = shift;
    carp "No default value specified"
        if not scalar @{$self->{'parameter'}};
    $self->{'default'} = $self->{'parameter'}->[0];
    return $self;
}

#@Override
sub filter
{
    my $self = shift;  # self
    shift;  # filter_manager
    my $value = shift;
    my $context = shift;
    
    return $value || $self->{'default'}->render($context);
}

1;