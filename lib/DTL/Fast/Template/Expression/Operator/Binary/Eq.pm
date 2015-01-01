package DTL::Fast::Template::Expression::Operator::Binary::Eq;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Expression::Operator::Binary';

$DTL::Fast::Template::Expression::Operator::KNOWN{'=='} = __PACKAGE__;

use Scalar::Util qw(looks_like_number);

# @todo Recurursion protection on deep comparision or one-level comparision
sub dispatch
{
    my( $self, $arg1, $arg2) = @_;
    my ($arg1_type, $arg2_type) = (ref $arg1, ref $arg2);
    my $result = 0;
    
    if( looks_like_number($arg1) and looks_like_number($arg2))
    {
        $result = ($arg1 == $arg2);
    }
    elsif( $arg1_type eq 'ARRAY'  and $arg2_type eq 'ARRAY' )
    {
        if( scalar @$arg1 == scalar @$arg2 )
        {
            $result = 1;
            for( my $i = 0; $i < scalar @$arg1; $i++ )
            {
                if( not $self->dispatch($arg1->[$i], $arg2->[$i] ))
                {
                    $result = 0;
                    last;
                }
            }
        }
    }
    elsif( $arg1_type eq 'HASH' and $arg2_type eq 'HASH' )
    {
        my @keys1 = sort keys %$arg1;
        my @keys2 = sort keys %$arg2;
        
        if( $self->dispatch( \@keys1, \@keys2 ) )
        {
            my $result = 1;
            foreach my $key (@keys1)
            {
                if( not $self->dispatch($arg1->{$key}, $arg2->{$key} ))
                {
                    $result = 0;
                    last;
                }
            }
        }        
    }
    elsif( $arg1_type and $arg1->can('equal'))
    {
        $result = $arg1->equal($arg2);
    }
    else
    {
        $result = ($arg1 eq $arg2);
    }
    
    return $result;
}

1;