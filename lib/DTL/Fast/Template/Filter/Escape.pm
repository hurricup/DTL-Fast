package DTL::Fast::Template::Filter::Escape;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter';
use Carp qw(confess);

$DTL::Fast::Template::FILTER_HANDLERS{'escape'} = __PACKAGE__;
$DTL::Fast::Template::FILTER_HANDLERS{'force_escape'} = __PACKAGE__;

use DTL::Fast::Utils;

# filtering function
sub filter
{
    shift;  # self
    shift->{'safe'} = 1;    # filter_manager
    return DTL::Fast::Utils::html_protect(shift);
}

1;