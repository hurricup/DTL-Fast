package DTL::Fast::Template::Tag::Include;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Tag';  # block-based tags should be inherited from Iterator, not Tag

$DTL::Fast::Template::TAG_HANDLERS{'include'} = __PACKAGE__;

use DTL::Fast::Context;
use DTL::Fast::Template::Expression;

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
    
#    warn "Invoked with $parameter";
    
    # parent class just blesses passed hash with proto. Nothing more. 
    # Use it for future compatibility
    return $proto->SUPER::new(
    {
        'template' => DTL::Fast::Template::Expression->new($parameter)
        , 'dirs' => $kwargs{'dirs'}
    });    
}

# Processing function
# @todo: recursion protection
sub render
{
    my $self = shift;
    my $context = shift // DTL::Fast::Context->new();
    
#    use Data::Dumper;warn "rendering invoked ".Dumper($self);
    
    my $result = DTL::Fast::get_template(
        $self->{'template'}->render($context)
        , $self->{'dirs'}
    );
    
    return $result->render($context);
}

1;