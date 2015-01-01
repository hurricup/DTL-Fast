package DTL::Fast::Template::Expression::Operator::Binary::And;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Expression::Operator::Binary';

$DTL::Fast::Template::Expression::Operator::KNOWN{'and'} = __PACKAGE__;

sub dispatch
{
    my( $self, $arg1, $arg2) = @_;
    my ($arg1_type, $arg2_type) = (ref $arg1, ref $arg2);
    
    if( $arg1_type and $arg1->can('and') )
    {
        return $arg1->and($arg2);
    }
    else
    {
        return $arg1 && $arg2;
    }
}

1;