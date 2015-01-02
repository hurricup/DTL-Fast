package DTL::Fast::Template::Expression::Operator::Binary::NotIn;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Expression::Operator::Binary::In';
use Carp qw(confess);

$DTL::Fast::Template::Expression::Operator::KNOWN{'not in'} = __PACKAGE__;

sub dispatch
{
    my( $self, $arg1, $arg2) = @_;
    
    return !$self->SUPER::dispatch($arg1, $arg2);
}

1;