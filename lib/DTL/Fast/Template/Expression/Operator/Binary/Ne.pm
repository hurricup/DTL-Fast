package DTL::Fast::Template::Expression::Operator::Binary::Ne;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Expression::Operator::Binary::Eq';

$DTL::Fast::Template::Expression::Operator::KNOWN{'!='} = __PACKAGE__;
$DTL::Fast::Template::Expression::Operator::KNOWN{'<>'} = __PACKAGE__;

use Scalar::Util qw(looks_like_number);

sub dispatch
{
    my( $self, $arg1, $arg2) = @_;
    return !$self->SUPER::dispatch($arg1, $arg2);
}

1;