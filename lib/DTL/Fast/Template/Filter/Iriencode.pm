package DTL::Fast::Template::Filter::Iriencode;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter::Urlencode';
use Carp qw(confess);

$DTL::Fast::Template::FILTER_HANDLERS{'iriencode'} = __PACKAGE__;

1;