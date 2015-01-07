package DTL::Fast::Template::Filter::Linebreaks;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter';
use Carp qw(confess);

$DTL::Fast::Template::FILTER_HANDLERS{'linebreaks'} = __PACKAGE__;

#@Override
sub filter
{
    shift;  # self
    my $filter_manager = shift;  # filter_manager
    my $value = shift;  # value
    shift;  # context

    $filter_manager->{'safe'} = 1;
    $value =~ s/(^\s+|\s+$)//gs;
    $value =~ s/\n\n+/<\/p>\n<p>/gs;
    $value =~ s/(?<!<\/p>)\n/<br \/>\n/gsi;
    $value = "<p>$value</p>" if $value;
    
    return $value;
}

1;