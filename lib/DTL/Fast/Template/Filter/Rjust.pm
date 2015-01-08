package DTL::Fast::Template::Filter::Rjust;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter::Center';
use Carp qw(confess);

$DTL::Fast::Template::FILTER_HANDLERS{'rjust'} = __PACKAGE__;

#@Override
sub adjust
{
    my $self = shift;
    my $value = shift;
    my $adjustment = shift;
    return (' 'x $adjustment).$value;
}

1;