package DTL::Fast::Tag::Extends;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Tag::Simple';
use Carp;

$DTL::Fast::TAG_HANDLERS{'extends'} = __PACKAGE__;

#@Override
sub parse_parameters
{
    my $self = shift;

    croak sprintf("Structure error. Top-level object for %s must be a DTL::Fast::Template, not %s (%s)"
        , __PACKAGE__
        , $self->{'_template'} // 'undef'
        , ref $self->{'_template'} || 'SCALAR' 
    ) if not $self->{'_template'}
        or not ref $self->{'_template'}
        or not $self->{'_template'}->isa('DTL::Fast::Template')
    ;
    
    my $parent_template = '';
    croak "Parent template was not specified"
        if not $self->{'parameter'}
            or not ($parent_template = DTL::Fast::Variable->new($self->{'parameter'})->render());
            
    carp sprintf("Multiple extends specified in the template:\n\%s\n\%s\n"
        , $self->{'_template'}->{'extends'}
        , $parent_template
    ) if $self->{'_template'}->{'extends'};
            
    $self->{'_template'}->{'extends'} = $parent_template;
    
    return undef;
}

1;