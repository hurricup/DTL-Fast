package DTL::Fast::Renderer;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Replacer';
use Carp qw(confess);

use DTL::Fast::Utils;
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
    my( $self, $context ) = @_;
  

    my $is_safe = $context->get('_dtl_safe') // 0;
  
    return join '', map{ 
        my $text = '';

        $text = $_->render($context);
        
        if(
            $_->isa('DTL::Fast::Variable')
            and not $_->{'filter_manager'}->{'safe'}
            and not $is_safe
        )
        {
            $text = DTL::Fast::Utils::html_protect($text);
        }
        $text // '';# // '_UNDEF_'; # temporary solution for catching bugs
    } @{$self->{'chunks'}};
}

1;