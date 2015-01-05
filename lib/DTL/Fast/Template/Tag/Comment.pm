package DTL::Fast::Template::Tag::Comment;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Tag';  
use Carp qw(confess);

$DTL::Fast::Template::TAG_HANDLERS{'comment'} = __PACKAGE__;

#@Override
sub get_close_tag{return 'endcomment';}

#@Override
sub parse_parameters
{
    my $self = shift;
    $self->{'nested_comments'} = 0;
    return $self;
}

#@Override
sub parse_next_chunk
{
    my $self = shift;
    my $chunk = shift @{$self->{'raw_chunks'}};
    
    if
    ( 
        $chunk =~ /^\{\% ([^\s]+?)(?: (.*?))? \%\}$/ 
    )
    {
        $chunk = $self->parse_tag_chunk($1, $2);
    }
    else
    {
        $chunk = undef;
    }
    
    return $chunk;
}

#@Override
sub parse_tag_chunk
{
    my $self = shift;
    my $tag_name = shift;
    my $tag_param = shift;
    
    my $result = undef;
    
    if( $tag_name eq $self->get_close_tag )
    {
        if( $self->{'nested_comments'} )
        {
            $self->{'nested_comments'}--;
        }
        else
        {
            $self->{'raw_chunks'} = [];
        }
    }
    elsif( $tag_name eq 'comment' )
    {
        $self->{'nested_comments'}++;
    }
    elsif( $tag_name eq 'uncomment' )
    {
        $result = $self->SUPER::parse_tag_chunk($tag_name, $tag_param);
    }
    
    return $result;
}

1;