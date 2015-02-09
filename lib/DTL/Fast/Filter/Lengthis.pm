package DTL::Fast::Filter::Lengthis;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Filter::Length';

$DTL::Fast::FILTER_HANDLERS{'length_is'} = __PACKAGE__;


#@Override
sub parse_parameters
{
    my $self = shift;
    die "No length value specified"
        if not scalar @{$self->{'parameter'}};
    $self->{'length'} = $self->{'parameter'}->[0];
    return $self;
}

#@Override
sub filter
{
    my $self = shift;  # self
    shift;  # filter_manager
    my $value = shift;  # value
    my $context = shift;  # context

    my $length = $self->SUPER::filter(undef, $value);
    return $length == $self->{'length'}->render($context) ?
        1
        : 0;
}

1;