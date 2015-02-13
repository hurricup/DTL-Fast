package DTL::Fast::Tag::Extends;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Tag::Simple';

$DTL::Fast::TAG_HANDLERS{'extends'} = __PACKAGE__;

use DTL::Fast::Template;

#@Override
sub parse_parameters
{
    my $self = shift;
    
    my $parent_template = '';
    die "Parent template was not specified"
        if not $self->{'parameter'}
            or not ($parent_template = DTL::Fast::Variable->new($self->{'parameter'})->render());
            
    die sprintf("Multiple extends specified in the template:\n\%s\n\%s\n"
        , $DTL::Fast::Template::CURRENT_TEMPLATE->{'extends'} // 'undef'
        , $parent_template // 'undef'
    ) if $DTL::Fast::Template::CURRENT_TEMPLATE->{'extends'};
            
    $DTL::Fast::Template::CURRENT_TEMPLATE->{'extends'} = $parent_template;
    
    return;
}

1;