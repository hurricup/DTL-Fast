package DTL::Fast::Template::Parser;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Renderer';
use Carp qw(confess cluck);

use DTL::Fast::Template::Expression;

sub new
{
    my $proto = shift;
    my %kwargs = @_;

    confess 'No directory arrays passed into constructor'
        if not $kwargs{'dirs'}
            or ref $kwargs{'dirs'} ne 'ARRAY'
        ;
    
    confess 'No raw chunks array passed into constructor'
        if not $kwargs{'raw_chunks'}
            or ref $kwargs{'raw_chunks'} ne 'ARRAY'
        ;
    
    $kwargs{'safe'} //= 0;

    return $proto->SUPER::new(%kwargs)->parse_chunks();
}

sub parse_chunks
{
    my $self = shift;
    while( scalar @{$self->{'raw_chunks'}} )
    {
         $self->add_chunk( $self->parse_next_chunk());
    }
    return $self;
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
    elsif( $chunk )
    {
        $chunk = DTL::Fast::Template::Text->new( $chunk );
    }
    else
    {
        $chunk = undef;
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
        $result = DTL::Fast::Template::Text->new( "" );
    }
    
    return $result;
}

1;