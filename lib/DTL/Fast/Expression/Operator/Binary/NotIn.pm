package DTL::Fast::Expression::Operator::Binary::NotIn;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Expression::Operator::Binary::In';
use Carp qw(confess);

$DTL::Fast::Expression::Operator::KNOWN{'not in'} = __PACKAGE__;

sub render
{
    my $self = shift;
    return !$self->SUPER::render(@_);
}

1;