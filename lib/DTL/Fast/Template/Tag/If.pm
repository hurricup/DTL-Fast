package DTL::Fast::Template::Tag::If;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::BlockTag';  

$DTL::Fast::Template::TAG_HANDLERS{'if'} = __PACKAGE__;

use DTL::Fast::Context;
use DTL::Fast::Template::Expression;
use DTL::Fast::Template::Tag::If::Condition;

# atm gets arguments: 
# parameter - opening tag params
# named:
#   dirs: arrayref of template directories
#   raw_chunks: current raw chunks queue
sub new
{
    my $proto = shift;
    my $condition = shift;  # parameter of the opening tag
    my %kwargs = @_;
    
    # parent class just blesses passed hash with proto. Nothing more. 
    # Use it for future compatibility
    my $self = $proto->SUPER::new( 
        $kwargs{'raw_chunks'}
        , $kwargs{'dirs'}
        , 'conditions' => [
            DTL::Fast::Template::Tag::If::Condition->new($condition)
        ]
    );    
    
    return $self;
}

# add chunk to the last condition
sub add_chunk
{
    my $self = shift;
    my $chunk = shift;
    
    $self->{'conditions'}->[-1]->add_chunk($chunk);
}

# parse extra tags from if blocks
sub parse_tag_chunk
{
    my $self = shift;
    my $tag_name = shift;
    my $tag_param = shift;
    
    my $result = undef;

    if( $tag_name eq 'endif' )
    {
        $self->{'raw_chunks'} = [];
    }
    elsif( $tag_name eq 'elif' or $tag_name eq 'elsif' )
    {
        push @{$self->{'conditions'}}, DTL::Fast::Template::Tag::If::Condition->new($tag_param);
    }
    elsif( $tag_name eq 'else' )
    {
        push @{$self->{'conditions'}}, DTL::Fast::Template::Tag::If::Condition->new(1);
    }
    else
    {
        $result = $self->SUPER::parse_tag_chunk($tag_name, $tag_param);
    }
    
    return $result;
}

# conditional rendering
sub render
{
    my $self = shift;
    my $context = shift;
    my $result = '';
    
    foreach my $condition (@{$self->{'conditions'}})
    {
        if( $condition->is_true($context) )
        {
            $result = $condition->render($context);
            last;
        }
    }
    return $result;
}

1;