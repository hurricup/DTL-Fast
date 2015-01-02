package DTL::Fast::Template::Iterator;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Renderer';
use Carp qw(confess);

use DTL::Fast::Template::Expression;

sub new
{
    my $proto = shift;
    my $raw_chunks = shift;
    my $dirs = shift // [];
    my %kwargs = @_;

    $kwargs{'dirs'} = $dirs;
    $kwargs{'raw_chunks'} = $raw_chunks;
    
    confess "Source chunks not passed to the constructor"
        if not $kwargs{'raw_chunks'}
            or ref $kwargs{'raw_chunks'} ne 'ARRAY';
    
    my $self = $proto->SUPER::new(%kwargs);

    $self->parse_chunks();
    
    return $self;
}

sub parse_chunks
{
    my $self = shift;
    
    while( scalar @{$self->{'raw_chunks'}} )
    {
         $self->add_chunk( $self->parse_next_chunk());
    }
}

sub parse_next_chunk
{
    my $self = shift;
    my $chunk = shift @{$self->{'raw_chunks'}};
    
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
        $chunk = $self->parse_tag_chunk($1, $2);
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
    
    my $result = undef;

    if( exists $DTL::Fast::Template::TAG_HANDLERS{$tag_name} )
    {        
        $result = $DTL::Fast::Template::TAG_HANDLERS{$tag_name}->new($tag_param
            , 'raw_chunks' => $self->{'raw_chunks'}
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


1;