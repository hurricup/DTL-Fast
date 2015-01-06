package DTL::Fast::Template::Filter::DefaultIfNone;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter::Default';
use Carp qw(confess);

$DTL::Fast::Template::FILTER_HANDLERS{'default_if_none'} = __PACKAGE__;

#@Override
sub filter
{
    my $self = shift;  # self
    shift;  # filter_manager
    my $value = shift;
    my $context = shift;
    
    return $value // $self->{'default'}->render($context);
}

1;