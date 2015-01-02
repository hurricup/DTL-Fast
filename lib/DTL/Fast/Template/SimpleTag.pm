package DTL::Fast::Template::SimpleTag;
use strict; use utf8; use warnings FATAL => 'all'; 

sub new
{
    my $proto = shift;
    my %kwargs = @_;
    return bless {%kwargs}, $proto;
}

1;
