package DTL::Fast::Expression::Operator::Binary::Ge;
use strict; use utf8; use warnings FATAL => 'all';
use parent 'DTL::Fast::Expression::Operator::Binary';

$DTL::Fast::Expression::Operator::KNOWN{'>='} = __PACKAGE__;

use Scalar::Util qw(looks_like_number);

sub dispatch
{
    my( $self, $arg1, $arg2) = @_;
    my ($arg1_type, $arg2_type) = (ref $arg1, ref $arg2);
    my $result = 0;

    if( looks_like_number($arg1) and looks_like_number($arg2))
    {
        $result = ($arg1 >= $arg2);
    }
    elsif( $arg1_type eq 'ARRAY'  and $arg2_type eq 'ARRAY' ) # @todo check that $arg1 includes $arg2
    {
        $result = ( scalar @$arg1 >= scalar @$arg2 );
    }
    elsif( $arg1_type eq 'HASH' and $arg2_type eq 'HASH' ) # @todo check that $arg1 includes $arg2
    {
        my @keys1 = sort keys %$arg1;
        my @keys2 = sort keys %$arg2;

        $result = ( scalar @$arg1 >= scalar @$arg2 );
    }
    elsif( UNIVERSAL::can($arg1, 'compare'))
    {
        $result = ( $arg1->compare($arg2) > -1 );
    }
    else
    {
        $result = ($arg1 ge $arg2);
    }

    return $result;
}

1;
