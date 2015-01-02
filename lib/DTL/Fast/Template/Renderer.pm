package DTL::Fast::Template::Renderer;
use strict; use utf8; use warnings FATAL => 'all'; 
use Carp qw(confess);

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
    
    confess "Context must be a DTL::Fast::Context object"
        if(
            defined $context
            and ref $context ne 'DTL::Fast::Context'
        );
        
    return join '', map{ 
        $_->render($context)
    } @{$self->{'chunks'}};
}


1;