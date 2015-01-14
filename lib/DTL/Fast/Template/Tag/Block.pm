package DTL::Fast::Template::Tag::Block;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Tag';  
use Carp;

$DTL::Fast::Template::TAG_HANDLERS{'block'} = __PACKAGE__;

#@Override
sub get_close_tag{return 'endblock';}

#@Override
sub parse_parameters
{
    my $self = shift;

    croak sprintf("Structure error. Top-level object must be a DTL::Fast::Template, not %s (%s)"
        , $self->{'_parent'} // 'undef'
        , ref $self->{'_parent'} || 'SCALAR' 
    ) if not $self->{'_parent'}
        or not ref $self->{'_parent'}
        or not $self->{'_parent'}->isa('DTL::Fast::Template')
    ;
    
    $self->{'_parent'}->add_block($self->{'parameter'}, $self);
    
    return $self;
}

1;