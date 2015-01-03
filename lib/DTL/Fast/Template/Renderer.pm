package DTL::Fast::Template::Renderer;
use strict; use utf8; use warnings FATAL => 'all'; 
use Carp qw(confess);

use DTL::Fast::Utils;
use DTL::Fast::Context;

sub new
{
    my $proto = shift;
    my %kwargs = @_;
    
    $kwargs{'chunks'} = [];

    my $self = bless {%kwargs}, $proto;

    return $self;
}

sub add_chunk
{
    my $self = shift;
    my $chunk = shift;
    
    push @{$self->{'chunks'}}, $chunk if defined $chunk;
}

sub render
{
    my $self = shift;
    my $context = shift;

    $context //= {};
    
    if( ref $context eq 'HASH' )
    {
        $context = DTL::Fast::Context->new($context);
    }
    elsif( 
        defined $context 
        and ref $context ne 'DTL::Fast::Context'
    )
    {
        confess "Context must be a DTL::Fast::Context object or a HASH reference";
    }
    
    my $is_safe = $context->get('_dtl_safe') // 0;
#    my $is_commented = $context->get('_dtl_commented') // 0;
  
    return join '', map{ 
        my $text = '';

        # if( 
            # not $is_commented
            # or $_->isa('DTL::Fast::Template::Tag::Uncomment')
        # )
        # {
            $text = $_->render($context);
            
            if(
                $_->isa('DTL::Fast::Template::Variable')
                and not $_->{'safe'}
                and not $is_safe
            )
            {
                $text = DTL::Fast::Utils::html_protect($text);
            }
 #       }
        $text;
    } @{$self->{'chunks'}};
}

1;