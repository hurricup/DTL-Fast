package DTL::Fast::Template::Tag::Uncomment;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::BlockTag';  
use Carp qw(confess);

$DTL::Fast::Template::TAG_HANDLERS{'uncomment'} = __PACKAGE__;

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
    
    # parent class just blesses passed hash with proto. Nothing more. 
    # Use it for future compatibility
    my $self = $proto->SUPER::new( %kwargs );
    
    return $self;
}

# parse extra tags from if blocks
sub parse_tag_chunk
{
    my $self = shift;
    my $tag_name = shift;
    my $tag_param = shift;
    
    my $result = undef;

    if( $tag_name eq 'enduncomment' )
    {
        $self->{'raw_chunks'} = [];
    }
    else
    {
        $result = $self->SUPER::parse_tag_chunk($tag_name, $tag_param);
    }
    
    return $result;
}


1;