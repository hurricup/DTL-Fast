package DTL::Fast::Filter::Random;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Filter';

$DTL::Fast::FILTER_HANDLERS{'random'} = __PACKAGE__;

#@Override
#@todo this method should be locale-specific
sub filter
{
    shift;  # self
    shift;  # filter_manager
    my $value = shift; # value
    shift; # context
    
    die sprintf("Argument must be an ARRAY ref, not %s (%s)"
        , $value // 'undef'
        , ref $value || 'SCALAR'
    ) if ref $value ne 'ARRAY';

    return $value->[int(rand scalar @$value)];
}

1;