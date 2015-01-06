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
        my $adjustment = int(($width - length $value) / 2);
        if( $adjustment > 0 )
        {
            $value = (' 'x $adjustment).$value;
        }
    }
    else
    {
        die "Argument must be a positive number, not '$width'";
    }
    return $value;
}

1;