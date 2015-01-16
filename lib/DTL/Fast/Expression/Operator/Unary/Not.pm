package DTL::Fast::Expression::Operator::Unary::Not;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Expression::Operator::Unary::Logical';

$DTL::Fast::Expression::Operator::KNOWN{'not'} = __PACKAGE__;

use DTL::Fast::Utils qw(has_method);

sub dispatch
{
    my( $self, $arg1) = @_;
    my $arg1_type = ref $arg1;
    
    if( has_method($arg1, 'not'))
    {
        return $arg1->not();
    }
    else
    {
        return !$arg1;
    }
}

1;