package DTL::Fast::Template::Filter::Urlizetrunc;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter::Urlize';
use Carp;

$DTL::Fast::Template::FILTER_HANDLERS{'urlizetrunc'} = __PACKAGE__;

#@Override
sub parse_parameters
{
    my $self = shift;
    croak "No max size specified"
        if not scalar @{$self->{'parameter'}};
    $self->{'maxsize'} = $self->{'parameter'}->[0];
    return $self;
}

#@Override
sub filter
{
    my $self = shift;  # self
    my $filter_manager = shift;  # filter_manager
    my $value = shift;  # value
    my $context = shift;    #context
    
    $self->{'size'} = $self->{'maxsize'}->render($context);
    return $self->SUPER::filter($filter_manager, $value, $context);
}

#@Override
sub normalize_text
{
    my $self = shift;
    my $text = shift;
    
    if( length $text > $self->{'size'} )
    {
        $text = substr $text, 0, $self->{'size'};
        $text =~ s/\s*$/.../s;
    }
    
    return $text;
}

1;