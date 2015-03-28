package DTL::Fast::Text;
use strict; use utf8; use warnings FATAL => 'all'; 

use DTL::Fast::Template;

sub new
{
    my ($proto, $text ) = @_;
    $text //= '';
    
    return bless {
        'texts' => [$text]
        , '_template' => $DTL::Fast::Template::CURRENT_TEMPLATE
        , '_template_line' => $DTL::Fast::Template::CURRENT_TEMPLATE_LINE
    }, $proto;
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