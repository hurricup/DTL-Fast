package DTL::Fast::Template::Filter::Wordwrap;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter';
use Carp;

$DTL::Fast::Template::FILTER_HANDLERS{'wordwrap'} = __PACKAGE__;

#@Override
sub parse_parameters
{
    my $self = shift;
    croak "No wrapping width specified"
        if not scalar @{$self->{'parameter'}};
    $self->{'maxwidth'} = $self->{'parameter'}->[0];
    return $self;
}


#@Override
sub filter
{
    my $self = shift;  # self
    shift;  # filter_manager
    my $value = shift;
    my $context = shift;  # context

    my $maxwidth = $self->{'maxwidth'}->render($context);
    my @value = split /\s+/s, $value;
    my @result = ();
    my $width = 0;
    
    foreach my $value (@value)
    {
        my $length = length $value;
        if( $width ==  0 )
        {
            push @result, $value;
            $width += $length;
        }
        elsif( $length + $width + 1 > $maxwidth )
        {
            push @result, "\n", $value;
            $width = $length;
        }
        else
        {
            push @result, ' ', $value;
            $width += $length + 1;
        }
    }
    
    return join '', @result;
}

1;