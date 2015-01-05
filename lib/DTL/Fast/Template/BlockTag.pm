package DTL::Fast::Template::BlockTag;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Iterator';

sub end_block
{
    my $self = shift;
    $self->{'raw_chunks'} = [];
    return $self;
}

# Close tag processor
sub parse_tag_chunk
{
    my $self = shift;
    my $tag_name = shift;
    my $tag_param = shift;
    
    my $result = undef;

    if( $tag_name eq $self->{'close_tag'} )
    {
        $self->end_block();
    }
    else
    {
        $result = $self->SUPER::parse_tag_chunk($tag_name, $tag_param);
    }
    
    return $result;
}


1;
