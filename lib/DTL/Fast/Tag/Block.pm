package DTL::Fast::Tag::Block;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Tag';  

use Data::Dumper;

our $VERSION = '1.00';

$DTL::Fast::TAG_HANDLERS{'block'} = __PACKAGE__;

#@Override
sub get_close_tag{return 'endblock';}

#@Override
sub parse_parameters
{
    my( $self ) = @_;

    $self->{'block_name'} = $self->{'parameter'};
    
    die "No name specified in the block tag" if not $self->{'block_name'};

    # registering block within template    
    if ( exists $DTL::Fast::Template::CURRENT_TEMPLATE->{'blocks'}->{$self->{'block_name'}} )
    {
        die "Block name must be unique in the template. Duplicated block: $self->{'block_name'}";
    }
    else
    {
        $DTL::Fast::Template::CURRENT_TEMPLATE->{'blocks'}->{$self->{'block_name'}} = $self;
    }
    
    return $self;
}

#@Override
sub render
{
    my( $self, $context ) = @_;
    
    my $result;
    
    $context->push_scope();
    my $ns = $context->{'ns'}->[-1];
    
    $ns->{'_dtl_rendering_block'} = $self;
    
    if ( $ns->{'_dtl_descendants'} )
    {
        # template with inheritance
        foreach my $descendant (@{$ns->{'_dtl_descendants'}})
        {
            if ( $descendant == $self )
            {
                $result = $self->SUPER::render($context);
                last;
            }
            elsif($descendant->{'blocks'}->{$self->{'block_name'}})
            {
                $ns->{'_dtl_rendering_template'} = $descendant;
                $result = $descendant->{'blocks'}->{$self->{'block_name'}}->SUPER::render($context);
                last;
            }
        }
    }
    else
    {
        # simple template
        $result = $self->SUPER::render($context);   
    }    
    $context->pop_scope();
    
    return $result;    
}

1;