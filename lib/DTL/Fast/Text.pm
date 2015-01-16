package DTL::Fast::Text;
use strict; use utf8; use warnings FATAL => 'all'; 

sub new
{
    my $proto = shift;
    my $text = shift // '';
    
    return bless {'texts' => [$text]}, $proto;
}

sub append
{
    my $self = shift;
    push @{$self->{'texts'}}, shift;
    return $self;
}

sub render{ return join '', @{shift->{'texts'}};}

1;