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
    $self->{'need_join'} ||= 1;
    push @{$self->{'texts'}}, shift;
    return $self;
}

sub render
{
    my($self) = @_;
    return $self->{'need_join'}
        ? join '', @{$self->{'texts'}}
        : $self->{'texts'}->[0]
    ;
}


1;