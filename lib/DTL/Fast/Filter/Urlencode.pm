package DTL::Fast::Filter::Urlencode;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Filter';
use Carp qw(confess);

$DTL::Fast::FILTER_HANDLERS{'urlencode'} = __PACKAGE__;

use DTL::Fast::Utils;

#@Override
sub filter
{
    shift;  # self
    shift;  # filter_manager
    my $value = shift;  # value
    shift;    #context
    
    return DTL::Fast::Utils::escape($value);
}

1;