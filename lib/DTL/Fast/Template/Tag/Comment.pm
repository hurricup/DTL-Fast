package DTL::Fast::Template::Tag::Comment;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::BlockTag';  
use Carp qw(confess);

$DTL::Fast::Template::TAG_HANDLERS{'comment'} = __PACKAGE__;

# atm gets arguments: 
# parameter - opening tag params
# named:
#   dirs: arrayref of template directories
#   raw_chunks: current raw chunks queue
sub new
{
    my $proto = shift;
    my $parameter = shift;  # parameter of the opening tag
    my %kwargs = @_;
    
    $kwargs{'nested_comments'} = 0;
    # parent class just blesses passed hash with proto. Nothing more. 
    # Use it for future compatibility
    my $self = $proto->SUPER::new( %kwargs );
    
    return $self;
}

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


# parse extra tags from if blocks
sub parse_tag_chunk
{
    my $self = shift;
    my $tag_name = shift;
    my $tag_param = shift;
    
    my $result = undef;
    
    if( $tag_name eq 'endcomment' )
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