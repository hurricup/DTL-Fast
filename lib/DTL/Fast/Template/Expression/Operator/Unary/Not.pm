package DTL::Fast::Template::Expression::Operator::Unary::Not;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Expression::Operator::Unary';

$DTL::Fast::Template::Expression::Operator::KNOWN{'not'} = __PACKAGE__;

sub dispatch
{
    my( $self, $arg1) = @_;
    my $arg1_type = ref $arg1;
    
    if( $arg1_type and $arg1->can('not') )
    {
        return $arg1->not();
    }
    else
    {
        return !$arg1;
    }
}

1;