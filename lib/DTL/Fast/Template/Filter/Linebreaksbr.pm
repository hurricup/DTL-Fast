package DTL::Fast::Template::Filter::Linebreaksbr;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter';
use Carp qw(confess);

$DTL::Fast::Template::FILTER_HANDLERS{'linebreaksbr'} = __PACKAGE__;

#@Override
sub filter
{
    shift;  # self
    my $filter_manager = shift;  # filter_manager
    my $value = shift;  # value
    shift;  # context

    $filter_manager->{'safe'} = 1;
    $value =~ s/\n/<br \/>\n/gsi;
    
    return $value;
}

1;