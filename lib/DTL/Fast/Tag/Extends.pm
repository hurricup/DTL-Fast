package DTL::Fast::Tag::Extends;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Tag::Simple';

$DTL::Fast::TAG_HANDLERS{'extends'} = __PACKAGE__;

use DTL::Fast::Template;

#@Override
sub parse_parameters
{
    my $self = shift;
    
    die "Parent template was not specified"
        if not $self->{'parameter'};
            
    die sprintf("Multiple extends specified in the template:\n\%s\n\%s\n"
        , $DTL::Fast::Template::CURRENT_TEMPLATE->{'extends'}->{'original'} // 'undef'
        , $self->{'parameter'} // 'undef'
    ) if $DTL::Fast::Template::CURRENT_TEMPLATE->{'extends'};
            
    $DTL::Fast::Template::CURRENT_TEMPLATE->{'extends'} = DTL::Fast::Variable->new($self->{'parameter'});
    
    return;
}

1;