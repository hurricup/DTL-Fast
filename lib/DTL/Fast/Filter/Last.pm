package DTL::Fast::Filter::Last;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Filter';
use Carp qw(confess);

$DTL::Fast::FILTER_HANDLERS{'last'} = __PACKAGE__;

#@Override
sub filter
{
    shift;  # self
    shift;  # filter_manager
    my $value = shift;  # value
    shift;  # context

    if( ref $value eq 'ARRAY' )
    {
        $value = $value->[-1];
    }
    else
    {
        die sprintf(
            "last filter may be applied only to an ARRAY reference, not %s (%s)"
            , $value // 'undef'
            , ref $value || 'SCALAR'
        );
    }
    
    return $value;
}

1;