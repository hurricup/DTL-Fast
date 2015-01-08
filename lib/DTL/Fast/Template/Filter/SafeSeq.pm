package DTL::Fast::Template::Filter::SafeSeq;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter';
use Carp qw(confess);

$DTL::Fast::Template::FILTER_HANDLERS{'safeseq'} = __PACKAGE__;

#@Override
sub filter
{
    shift;

    shift->{'safeseq'} = 1;
    
    return shift;
}

1;