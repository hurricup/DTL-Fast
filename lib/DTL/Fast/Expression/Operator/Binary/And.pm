package DTL::Fast::Expression::Operator::Binary::And;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Expression::Operator::Binary';

$DTL::Fast::Expression::Operator::KNOWN{'and'} = __PACKAGE__;

use DTL::Fast::Utils qw(has_method);

sub dispatch
{
    my( $self, $arg1, $arg2) = @_;
    my ($arg1_type, $arg2_type) = (ref $arg1, ref $arg2);
    
    if( has_method($arg1, 'and') )
    {
        return $arg1->and($arg2);
    }
    else
    {
        return $arg1 && $arg2;
    }
}

1;