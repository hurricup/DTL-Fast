package DTL::Fast::Template::Tag::Simple;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Tag';

sub new
{
    my $proto = shift;
    my $parameter = shift;
    my %kwargs = @_;
    $kwargs{'raw_chunks'} = []; # no chunks parsing
    return $proto->SUPER::new($parameter, %kwargs);
}

1;
