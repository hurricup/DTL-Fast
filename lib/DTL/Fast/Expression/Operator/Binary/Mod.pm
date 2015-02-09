package DTL::Fast::Expression::Operator::Binary::Mod;
use strict; use utf8; use warnings FATAL => 'all';
use parent 'DTL::Fast::Expression::Operator::Binary';

$DTL::Fast::Expression::Operator::KNOWN{'mod'} = __PACKAGE__;
$DTL::Fast::Expression::Operator::KNOWN{'%'} = __PACKAGE__;

use Scalar::Util qw(looks_like_number);

sub dispatch
{
    my( $self, $arg1, $arg2) = @_;
    my ($arg1_type, $arg2_type) = (ref $arg1, ref $arg2);
    my $result = 0;

    if( looks_like_number($arg1) and looks_like_number($arg2))
    {
        $result = ($arg1 % $arg2);
    }
    elsif( UNIVERSAL::can($arg1, 'mod'))
    {
        $result = $arg1->mod($arg2);
    }
    else
    {
        die "Don't know how to take $arg1 ($arg1_type) modulus $arg2 ($arg2_type)";
    }

    return $result;
}

1;
