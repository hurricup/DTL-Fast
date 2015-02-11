package DTL::Fast::Expression::Operator;
use strict; use utf8; use warnings FATAL => 'all'; 

our $VERSION = '1.00';

our $OPERATORS = [
    ['or', 'DTL::Fast::Expression::Operator::Binary']                       # 0
    , ['and', 'DTL::Fast::Expression::Operator::Binary']                    # 1
    , ['==|!=|<>|<=|>=|<|>', 'DTL::Fast::Expression::Operator::Binary']     # 2
    , ['[+-]', 'DTL::Fast::Expression::Operator::Binary']                   # 3
    , ['[*/%]|mod', 'DTL::Fast::Expression::Operator::Binary']              # 4
    , ['not\ in|in', 'DTL::Fast::Expression::Operator::Binary']             # 5
    , ['not', 'DTL::Fast::Expression::Operator::Unary']                     # 6
    , ['defined', 'DTL::Fast::Expression::Operator::Unary']                 # 7
    , ['[*]{2}', 'DTL::Fast::Expression::Operator::Binary']                 # 8
]; # 

our %KNOWN;

our %OPS;

use DTL::Fast::Expression::Operator::Unary;
use DTL::Fast::Expression::Operator::Binary;

sub new
{
    my( $proto, $operator, @args ) = @_;
    $operator = lc($operator);
    
    my $result = undef;

    if( $DTL::Fast::Expression::Operator::KNOWN{$operator} )
    {
        $result = $DTL::Fast::Expression::Operator::KNOWN{$operator}->new(@args);
    }
    else
    {
        die "Unknown operator '$operator'";
    }
    
    return $result;
}

# invoke with parameters:
#
#   '=' => [ priority, module ]
#
sub register_operator
{
    my %ops = @_;
    
    my %recompile = ();
    foreach my $operator (keys %ops)
    {
        my($priority, $module) = @{$ops{$operator}};
        
        die "Operator priority must be a number from 0 to 8"
            if $priority ;
        
        $OPS{$priority} //= {};
        $OPS{$priority}->{$operator} = $module;
    }
}

1;