package DTL::Fast::Template::Tag::Extends;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Tag::Simple';
use Carp;

$DTL::Fast::Template::TAG_HANDLERS{'extends'} = __PACKAGE__;

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
    
    my $parent_template = '';
    croak "Parent template was not specified"
        if not $self->{'parameter'}
            or not ($parent_template = DTL::Fast::Template::Variable->new($self->{'parameter'})->render());
            
    carp sprintf("Multiple extends specified in the template:\n\%s\n\%s\n"
        , $self->{'_parent'}->{'extends'}
        , $parent_template
    ) if $self->{'_parent'}->{'extends'};
            
    $self->{'_parent'}->{'extends'} = $parent_template;
    
    return undef;
}

1;