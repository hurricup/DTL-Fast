package DTL::Fast::Parser;
use strict; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Renderer';
use Carp;

use DTL::Fast::Expression;
use DTL::Fast::Text;

sub new
{
    my( $proto, %kwargs ) = @_;

    croak 'No directory arrays passed into constructor'
        if not $kwargs{'dirs'}
            or ref $kwargs{'dirs'} ne 'ARRAY'
        ;
    
    croak 'No raw chunks array passed into constructor'
        if not $kwargs{'raw_chunks'}
            or ref $kwargs{'raw_chunks'} ne 'ARRAY'
        ;
    
    $kwargs{'safe'} //= 0;
    $kwargs{'blocks'} = {};

    my $self = $proto->SUPER::new(%kwargs)->parse_chunks();
    
    delete @{$self}{'_template', '_container_block', 'raw_chunks'};
    
    return $self;
}

sub parse_chunks
{
    my( $self ) = @_;
    while( scalar @{$self->{'raw_chunks'}} )
    {
         $self->add_chunk( $self->parse_next_chunk());
    }
    return $self;
}

sub parse_next_chunk
{
    my( $self ) = @_;
    my $chunk = shift @{$self->{'raw_chunks'}};
    
#    warn "Processing chunk $chunk";
    if( $chunk =~ /^\{\{ (.+?) \}\}$/ )
    {
        $chunk = DTL::Fast::Variable->new($1);
    }
    elsif
    ( 
        $chunk =~ /^\{\% ([^\s]+?)(?: (.*?))? \%\}$/ 
    )
    {
        $chunk = $self->parse_tag_chunk($1, $2);
    }
    elsif
    ( 
        $chunk =~ /^\{\# .* \#\}$/ 
    )
    {
        $chunk = undef;
    }
    elsif( $chunk ne '' )
    {
        $chunk = DTL::Fast::Text->new( $chunk );
    }
    else
    {
        $chunk = undef;
    }
    
    return $chunk;
}

sub parse_tag_chunk
{
    my( $self, $tag_name, $tag_param ) = @_;
    
    my $result = undef;

    if( exists $DTL::Fast::TAG_HANDLERS{$tag_name} )
    {     
        $result = $DTL::Fast::TAG_HANDLERS{$tag_name}->new(
            $tag_param
            , 'raw_chunks' => $self->{'raw_chunks'}
            , 'dirs' => $self->{'dirs'}
            , '_template' => $self->{'_template'} // $self
            , '_container_block' => $self->get_container_block()
        );
    }
    else
    {
        warn sprintf ('Unknown tag: %s in %s'
            , $tag_name
            , ($self->{'_template'} // $self)->{'inherited'}->[0] // 'inline'
        );
        $result = DTL::Fast::Text->new();
    }
    
    return $result;
}

sub get_container_block{ 
    my( $self ) = @_;
    return $self->{'_container_block'} 
        // croak sprintf(
            "There is no container block in: %s", $self // 'undef'
        ); 
}

sub add_blocks
{
    my( $self, $blocks ) = @_;
    
    croak "Blocks must be a HASH reference" if ref $blocks ne 'HASH';
    
    foreach my $block_name (keys(%$blocks))
    {
        if( exists $self->{'blocks'}->{$block_name} )
        {
            croak "Block $block_name is already registered. Duplicate names are not allowed";
        }
        
        $self->{'blocks'}->{$block_name} = $blocks->{$block_name};
    }
    
    if( $self->{'_container'} )
    {
        $self->{'_container'}->add_blocks($blocks);
    }    
    
    return $self;
}

sub remove_blocks
{
    my ($self, $block_names ) = @_;

    croak "Blocks must be an ARRAY reference" if ref $block_names ne 'ARRAY';
     
    foreach my $block_name (@$block_names)
    {
        croak "Sub-block $block_name does not registered in current block."
            if not exists $self->{'blocks'}->{$block_name};
            
        delete $self->{'blocks'}->{$block_name};
    }
  
    if( $self->{'_container'} )
    {
        $self->{'_container'}->remove_blocks($block_names);
    }    
    
    return $self;
}

1;