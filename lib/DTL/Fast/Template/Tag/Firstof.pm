package DTL::Fast::Template::Tag::Firstof;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::SimpleTag';  

$DTL::Fast::Template::TAG_HANDLERS{'firstof'} = __PACKAGE__;

use DTL::Fast::Context;
use DTL::Fast::Template::Variable;

# atm gets arguments: 
# parameter - opening tag params
# named:
#   dirs: arrayref of template directories
#   raw_chunks: current raw chunks queue
sub new
{
    my $proto = shift;
    my $source = shift;  # parameter of the opening tag
    my %kwargs = @_;
    
    $kwargs{'source'} = $source;
    
    # parent class just blesses passed hash with proto. Nothing more. 
    # Use it for future compatibility
    my $self = $proto->SUPER::new( %kwargs );
    
    $self->{'sources'} = $self->parse_sources($self->{'source'});
    
    return $self;
}

# conditional rendering
sub render
{
    my $self = shift;
    my $context = shift;
    my $result = '';
    
    foreach my $source (@{$self->{'sources'}})
    {
        if( $result = $source->render($context) )
        {
            if( 
                not $context->get('_dtl_safe') 
                and not $source->is_safe()
            )
            {
                $result = DTL::Fast::Utils::html_protect($result);
            }
            last;
        }
    }
    return $result;
}

1;