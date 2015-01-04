package DTL::Fast::Template::Expression::Operator::Binary::Ne;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Expression::Operator::Binary::Eq';

$DTL::Fast::Template::Expression::Operator::KNOWN{'!='} = __PACKAGE__;
$DTL::Fast::Template::Expression::Operator::KNOWN{'<>'} = __PACKAGE__;

use Scalar::Util qw(looks_like_number);

sub render
{
    my $self = shift;
    return !$self->SUPER::render(@_);
}

1;