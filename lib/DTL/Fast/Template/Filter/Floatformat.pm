package DTL::Fast::Template::Filter::Floatformat;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter';
use Carp qw(confess);

$DTL::Fast::Template::FILTER_HANDLERS{'floatformat'} = __PACKAGE__;

use DTL::Fast::Template::Variable;

#@Override
sub parse_parameters
{
    my $self = shift;
    $self->{'digits'} = DTL::Fast::Template::Variable->new($self->{'parameter'}->[0])
        if scalar @{$self->{'parameter'}};
    return $self;
}

#@Override
sub filter
{
    my $self = shift;  # self
    shift;  # filter_manager
    my $value = shift;
    my $context = shift;

    my $digits = defined $self->{'digits'} ? $self->{'digits'}->render($context) : undef;
    
    if( 
        defined $digits 
        and $digits =~ /^\d+$/
    )
    {
        $value = sprintf "%.0${digits}f", $value;
    }
    
    return $value;
}

1;