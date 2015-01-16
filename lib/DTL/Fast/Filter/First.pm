package DTL::Fast::Filter::First;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Filter';
use Carp qw(confess);

$DTL::Fast::FILTER_HANDLERS{'first'} = __PACKAGE__;

#@Override
sub filter
{
    shift;  # self
    shift;  # filter_manager
    my $value = shift;  # value
    shift;  # context

    if( ref $value eq 'ARRAY' )
    {
        $value = $value->[0];
    }
    else
    {
        die sprintf(
            "first filter may be applied only to an ARRAY reference, not %s (%s)"
            , $value // 'undef'
            , ref $value || 'SCALAR'
        );
    }
    
    return $value;
}

1;