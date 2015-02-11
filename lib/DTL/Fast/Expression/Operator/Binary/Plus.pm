package DTL::Fast::Expression::Operator::Binary::Plus;
use strict; use utf8; use warnings FATAL => 'all';
use parent 'DTL::Fast::Expression::Operator::Binary';

$DTL::Fast::OPS_HANDLERS{'+'} = __PACKAGE__;

use Scalar::Util qw(looks_like_number);

sub dispatch
{
    my( $self, $arg1, $arg2, $context) = @_;
    my ($arg1_type, $arg2_type) = (ref $arg1, ref $arg2);

    if( looks_like_number($arg1) and looks_like_number($arg2))
    {
        return $arg1 + $arg2;
    }
    elsif( $arg1_type eq 'ARRAY' )
    {
        if( $arg2_type eq 'ARRAY' )
        {
            return [@$arg1, @$arg2];
        }
        elsif( $arg2_type eq 'HASH' )
        {
            return [@$arg1, %$arg2];
        }
        elsif( UNIVERSAL::can($arg2, 'as_array'))
        {
            return [@$arg1, @{$arg2->as_array($context)}];
        }
        else
        {
            return [@$arg1, $arg2];
        }
    }
    elsif( $arg1_type eq 'HASH' )
    {
        if( $arg2_type eq 'ARRAY' )
        {
            return {%$arg1, @$arg2};
        }
        elsif( $arg2_type eq 'HASH' )
        {
            return {%$arg1, %$arg2};
        }
        elsif( UNIVERSAL::can($arg2, 'as_hash'))
        {
            return {%$arg1, %{$arg2->as_hash($context)}};
        }
        else
        {
            die "Don't know how to add $arg2 ($arg2_type) to a HASH";
        }
    }
    elsif( UNIVERSAL::can($arg1, 'plus'))
    {
        return $arg1->plus($arg2, $context);
    }
    else
    {
        return $arg1.$arg2;
    }
}

1;
