package DTL::Fast::Template::Text;
use strict; use utf8; use warnings FATAL => 'all'; 

sub new
{
    my $proto = shift;
    my $text = shift;
    my $template = shift;
    
    return bless {'text' => $text}, $proto;
}

sub render{ return shift->{'text'};}

1;