package DTL::Fast::Template::Tag::Comment;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Tag';  

$DTL::Fast::Template::TAG_HANDLERS{'comment'} = __PACKAGE__;

use DTL::Fast::Template::Text;

#@Override
sub get_close_tag{return 'endcomment';}

#@Override
sub parse_next_chunk
{
    my $self = shift;
    my $chunk = shift @{$self->{'raw_chunks'}};
    
    if( $chunk eq '{% endcomment %}' )
    {
        $self->{'raw_chunks'} = []; # this stops parsing
    }
    
    return undef;
}

#@Override
sub render
{
    return '';
}

1;