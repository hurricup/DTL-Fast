package DTL::Fast::Template::Filter::Truncatecharshtml;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter::Truncatechars';
use Carp qw(confess);

$DTL::Fast::Template::FILTER_HANDLERS{'truncatechars_html'} = __PACKAGE__;

use DTL::Fast::Template::Variable;

#@Override
sub filter
{
    my $self = shift;  # self
    my $filter_manager = shift;  # filter_manager
    my $value = shift;
    my $context = shift;
    
    my @splitted = split /(<[^>]+?>)/s, $value;

    foreach my $value (@splitted)
    {
        if( $value !~ /^(<[^>]+?>|\s*)$/gs )
        {
            $value = $self->SUPER::filter($filter_manager, $value, $context);
            last;
        }
    }
    
    return join '', @splitted;
}

1;