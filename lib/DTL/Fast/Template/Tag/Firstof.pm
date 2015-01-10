package DTL::Fast::Template::Tag::Firstof;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Tag::Simple';  

$DTL::Fast::Template::TAG_HANDLERS{'firstof'} = __PACKAGE__;

use DTL::Fast::Utils;

#@Override
sub parse_parameters
{
    my $self = shift;
    $self->{'sources'} = $self->parse_sources($self->{'parameter'});
    return $self;
}

#@Override
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