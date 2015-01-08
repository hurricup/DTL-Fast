package DTL::Fast::Template::Filter::Pluralize;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter';
use Carp qw(confess);

$DTL::Fast::Template::FILTER_HANDLERS{'pluralize'} = __PACKAGE__;

use DTL::Fast::Template::Variable;

#@Override
sub parse_parameters
{
    my $self = shift;
    push @{$self->{'parameter'}}, '"s"'
        if not scalar @{$self->{'parameter'}};
    $self->{'suffix'} = DTL::Fast::Template::Variable->new($self->{'parameter'}->[0]);
    return $self;
}

#@Override
#@todo this method should be locale-specific
sub filter
{
    my $self = shift;  # self
    shift;  # filter_manager
    my $value = shift;
    my $context = shift;
    my @suffix = split /\s*,\s*/, $self->{'suffix'}->render($context);
    
    my $suffix_one = scalar @suffix > 1 ? 
        shift @suffix
        : '';
        
    my $suffix_more = shift @suffix;
    
    if( $value != 1 )
    {
        $value = $suffix_more;
    }
    else
    {
        $value = $suffix_one;
    }
    
    return $value;
}

1;