package DTL::Fast::Template::SimpleTag;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Renderer';

sub new
{
    my $proto = shift;
    my %kwargs = @_;
    return $proto->SUPER::new(%kwargs);
}

1;
