package DTL::Fast::Template::Filter;
use strict; use utf8; use warnings FATAL => 'all'; 

use DTL::Fast::Template;

sub new
{
    my $proto = shift;
    my $data = shift // {};
    return bless $data, $proto;
}

sub filter
{
    die "This is abstract method and it must be overrided";
}

1;
