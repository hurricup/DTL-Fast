package DTL::Fast::Template::Tag::Filter;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Tag';  
use Carp qw(confess);

$DTL::Fast::Template::TAG_HANDLERS{'filter'} = __PACKAGE__;

use DTL::Fast::Template::FilterManager;

#@Override
sub get_close_tag{ return 'endfilter';}

sub parse_parameters
{
    my $self = shift;
    $self->{'filter_manager'} = DTL::Fast::Template::FilterManager->new($self->{'parameter'});
    return $self;
}

#@Override
sub render
{
    my $self = shift;
    my $context = shift;
    my $result = '';

    return $self->{'filter_manager'}->filter(
        $self->SUPER::render($context)
        , $context
    );
}


1;