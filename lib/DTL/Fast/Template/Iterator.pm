package DTL::Fast::Template::Iterator;
use strict; use utf8; use warnings FATAL => 'all'; 

use DTL::Fast::Template::Expression;

sub new
{
    my $proto = shift;
    my $raw_chunks = shift;
    my $dirs = shift // [];
    
    my $self = bless
    {
        'dirs' => $dirs
        , 'chunks' => []
    }, $proto;

    $self->parse_chunks($raw_chunks);
    
    return $self;
}

sub parse_chunks
{
    my $self = shift;
    my $raw_chunks = shift;
    
    while( scalar @$raw_chunks )
    {
         $self->add_chunk( $self->parse_next_chunk($raw_chunks));
    }
}

sub add_chunk
{
    my $self = shift;
    my $chunk = shift;
    
    push @{$self->{'chunks'}}, $chunk if defined $chunk;
}

sub parse_next_chunk
{
    my $self = shift;
    my $raw_chunks = shift;
    my $chunk = shift @$raw_chunks;
    
#    warn "Processing chunk $chunk";
    if( $chunk =~ /^\{\{ (.+?) \}\}$/ )
    {
        $chunk = DTL::Fast::Template::Variable->new($1);
    }
    elsif
    ( 
        $chunk =~ /^\{\% ([^\s]+?)(?: (.*?))? \%\}$/ 
    )
    {
        $chunk = $self->parse_tag_chunk($1, $2, $raw_chunks);
    }
    else
    {
        $chunk = DTL::Fast::Template::Text->new( $chunk );
    }
    
    return $chunk;
}

sub parse_tag_chunk
{
    my $self = shift;
    my $tag_name = shift;
    my $tag_param = shift;
    my $raw_chunks = shift; 
    
    my $result = undef;

    if( exists $DTL::Fast::Template::TAG_HANDLERS{$tag_name} )
    {        
        $result = $DTL::Fast::Template::TAG_HANDLERS{$tag_name}->new($tag_param
            , 'raw_chunks' => $raw_chunks
            , 'dirs' => $self->{'dirs'}
        );
    }
    else
    {
        warn "Unknown tag: $tag_name";
        $result = DTL::Fast::Template::Text->new( "", $self );
    }
    
    return $result;
}

sub render
{
    my $self = shift;
    my $context = shift;
    
    die "Context must be a DTL::Fast::Context object"
        if(
            defined $context
            and ref $context ne 'DTL::Fast::Context'
        );
        
    return join '', map{ 
        $_->render($context)
    } @{$self->{'chunks'}};
}


1;