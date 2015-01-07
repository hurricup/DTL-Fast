package DTL::Fast::Template::Filter::Dictsortreversed;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter::Dictsort';
use Carp qw(confess);

$DTL::Fast::Template::FILTER_HANDLERS{'dictsortreversed'} = __PACKAGE__;

#@Override
sub sort_function
{
    my $self = shift;
    my $val1 = shift;
    my $val2 = shift;
    
    return $self->SUPER::sort_function($val2, $val1);
}

1;