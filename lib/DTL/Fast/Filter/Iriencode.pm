package DTL::Fast::Filter::Iriencode;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Filter::Urlencode';
use Carp qw(confess);

$DTL::Fast::FILTER_HANDLERS{'iriencode'} = __PACKAGE__;

1;