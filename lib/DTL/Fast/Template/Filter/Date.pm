package DTL::Fast::Template::Filter::date;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter';
use Carp qw(confess);

$DTL::Fast::Template::FILTER_HANDLERS{'date'} = __PACKAGE__;

use DTL::Fast::Template::Variable;
use DTL::Fast::Utils;

#@Override
#@todo make pre-defined formats from Django
sub parse_parameters
{
    my $self = shift;
    die "No format specified for a date"
        if not scalar @{$self->{'parameter'}};
    $self->{'format'} = DTL::Fast::Template::Variable->new($self->{'parameter'}->[0]);
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
    
    return DTL::Fast::Utils::time2str($format, $value);
}

1;