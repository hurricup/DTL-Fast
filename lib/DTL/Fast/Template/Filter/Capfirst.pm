package DTL::Fast::Template::Filter::Capfirst;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter';

$DTL::Fast::Template::FILTER_HANDLERS{'capfirst'} = __PACKAGE__;

#@Override
sub filter
{
    shift;  # self
    shift;  # filter_manager
    my $value = shift;
    $value =~ s/^(.)/\U$1/s;
    return $value;
}

1;