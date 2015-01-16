package DTL::Fast::Expression::Operator::Binary::In;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Expression::Operator::Binary';
use Carp qw(confess);

$DTL::Fast::Expression::Operator::KNOWN{'in'} = __PACKAGE__;

use DTL::Fast::Utils qw(has_method);
use DTL::Fast::Expression::Operator::Binary::Eq;

sub dispatch
{
    my( $self, $arg1, $arg2) = @_;
    my ($arg1_type, $arg2_type) = (ref $arg1, ref $arg2);
    my $result = undef;
    
    if( not $arg2_type and not $arg1_type ) # substring checking
    {   
        $result = index($arg2, $arg1) > -1 ? 1: 0;
    }
    elsif( not $arg1_type and $arg2_type eq 'ARRAY')  # operand in array
    {
        $result = 0;
        foreach my $a2 (@$arg2)
        {
            # @todo: deep comparision, shouldn't it be optional?
            if( DTL::Fast::Expression::Operator::Binary::Eq::dispatch($self, $arg1, $a2) )
            {
                $result = 1;
                last;
            }
        }
    }
    elsif( not $arg1_type and $arg2_type eq 'HASH')  # exists synonim
    {
        $result = exists $arg2->{$arg1} ? 1: 0;
    }
    elsif( $arg2_type eq 'ARRAY' and $arg1_type eq 'ARRAY')  # second operand is an ARRAY
    {
        $result = 1;
        foreach my $a1 (@$arg1)
        {
            my $found = 0;
            foreach my $a2 (@$arg2)
            {
                # @todo: deep comparision, shouldn't it be optional?
                if( DTL::Fast::Expression::Operator::Binary::Eq::dispatch($self, $a1, $a2) )
                {
                    $found = 1;
                    last;
                }
            }
            
            if( not $found )
            {
                $result = 0;
                last;
            }
        }
    }
    elsif( $arg2_type eq 'HASH' and $arg1_type eq 'HASH' )   # hash contains hash
    {
        $result = 1;
        foreach my $key1 (keys %$arg1)
        {
            if( 
                not exists $arg2->{$key1}
                # @todo: deep comparision, shouldn't it be optional?
                or not DTL::Fast::Expression::Operator::Binary::Eq::dispatch($self, $arg1->{$key1}, $arg2->{$key1})
            )
            {
                $result = 0;
                last;
            }
        }
    }

    # `in` method implementation
    if( 
        not defined $result 
        and has_method($arg1, 'in')
    )
    {
        $result = $arg1->in($arg2);
    }

    # `contains` method implementation
    if( 
        not defined $result 
        and has_method($arg2, 'contains')
    )
    {
        $result = $arg2->contains($arg1);
    }
    
    # still nothing
    if( not defined $result )
    {
        confess sprintf("Don't know how to check that %s (%s) is in %s (%s)"
            , $arg1
            , $arg1_type
            , $arg2
            , $arg2_type
        );
    }
    
    return $result;
}

1;