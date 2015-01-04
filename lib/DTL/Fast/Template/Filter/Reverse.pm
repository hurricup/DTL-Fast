package DTL::Fast::Template::Filter::Reverse;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter';
use Carp qw(confess);

$DTL::Fast::Template::FILTER_HANDLERS{'reverse'} = __PACKAGE__;

use DTL::Fast::Context;
use DTL::Fast::Template::Variable;
use DTL::Fast::Utils qw(has_method);

# filtering function
sub filter
{
    my $self = shift;
    my $filter_manager = shift;
    my $value = shift;
    my $context = shift // DTL::Fast::Context->new();
    my $result; 
    
    my $value_type = ref $value;
    
    if( $value_type eq 'ARRAY' )
    {
        $result = [reverse @$value];
    }
    elsif( $value_type eq 'HASH' )
    {
        $result = {reverse %$value};
    }
    elsif( has_method($value_type, 'reverse') )
    {
        $result = $value->reverse($context);
    }
    else
    {
        confess "Don't know how to reverse $value ($value_type)";
    }    
    
    return $result;
}

1;