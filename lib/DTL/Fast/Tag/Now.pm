package DTL::Fast::Tag::Now;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Tag::Simple';  

$DTL::Fast::TAG_HANDLERS{'now'} = __PACKAGE__;

use DTL::Fast::Utils;

#@Override
sub parse_parameters
{
    my $self = shift;
    
    die "No time format specified" unless $self->{'parameter'};
    $self->{'format'} = $self->parse_sources($self->{'parameter'})->[0];
    
    return $self;
}

#@Override
sub render
{
    my $self = shift;
    my $context = shift;
    
    return DTL::Fast::Utils::time2str_php( $self->{'format'}->render($context), time);
}


1;
