package DTL::Fast::Tag::Firstofdefined;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Tag::Firstof';  

$DTL::Fast::TAG_HANDLERS{'firstofdefined'} = __PACKAGE__;

# conditional rendering
sub render
{
    my $self = shift;
    my $context = shift;
    my $result = '';
    
    foreach my $source (@{$self->{'sources'}})
    {
        if( defined ($result = $source->render($context)))
        {
            if( 
                not $context->get('_dtl_safe') 
                and not $source->{'filter_manager'}->{'safe'}
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