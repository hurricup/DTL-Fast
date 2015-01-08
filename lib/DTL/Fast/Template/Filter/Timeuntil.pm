package DTL::Fast::Template::Filter::Timeuntil;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter::Timesince';
use Carp qw(confess);

$DTL::Fast::Template::FILTER_HANDLERS{'timeuntil'} = __PACKAGE__;

#@Override
sub time_diff
{
    my $self = shift;
    my $diff = shift;
    return $self->SUPER::time_diff(-$diff);
}

1;