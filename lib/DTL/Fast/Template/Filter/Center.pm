package DTL::Fast::Template::Filter::Center;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter';
use Carp qw(confess);

$DTL::Fast::Template::FILTER_HANDLERS{'center'} = __PACKAGE__;

use DTL::Fast::Template::Variable;


#@Override
sub parse_parameters
{
    my $self = shift;
    die "No width specified for adjusting"
        if not scalar @{$self->{'parameter'}};
    $self->{'width'} = DTL::Fast::Template::Variable->new($self->{'parameter'}->[0]);
    return $self;
}

#@Override
sub filter
{
    my $self = shift;  # self
    shift;  # filter_manager
    my $value = shift;
    my $context = shift;
    
    my $width = $self->{'width'}->render($context);
    
    if( $width =~ /^\d+$/ )
    {
        my $adjustment = ($width - length $value);
        if( $adjustment > 0 )
        {
            $value = $self->adjust($value, $adjustment);
        }
    }
    else
    {
        die "Argument must be a positive number, not '$width'";
    }
    return $value;
}

sub adjust
{
    my $self = shift;
    my $value = shift;
    my $adjustment = shift;
    return (' 'x int($adjustment/2)).$value;
}

1;