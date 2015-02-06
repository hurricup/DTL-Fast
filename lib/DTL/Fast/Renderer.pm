package DTL::Fast::Renderer;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Replacer';
use Carp qw(confess);

use DTL::Fast::Context;

sub new
{
    my( $proto, %kwargs ) = @_;

    $kwargs{'chunks'} = [];

    return $proto->SUPER::new(%kwargs);
}

sub add_chunk
{
    my( $self, $chunk ) = @_;
    
    push @{$self->{'chunks'}}, $chunk if defined $chunk;
    return $self;
}

sub render
{
    my( $self, $context, $global_safe ) = @_;

    $global_safe ||= $context->get('_dtl_safe') // 0;
  
  
    return join '', map{ 
        $_->render($context, $global_safe) // ''
    } @{$self->{'chunks'}};
}

1;