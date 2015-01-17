package DTL::Fast::Expression::Operator;
use strict; use utf8; use warnings FATAL => 'all'; 
use Carp;

our $VERSION = '1.00';

our $OPERATORS = [
    ['or', 'DTL::Fast::Expression::Operator::Binary']
    , ['and', 'DTL::Fast::Expression::Operator::Binary']
    , ['==|!=|<>|<=|>=|<|>', 'DTL::Fast::Expression::Operator::Binary']
    , ['[+-]', 'DTL::Fast::Expression::Operator::Binary']
    , ['[*/%]|mod', 'DTL::Fast::Expression::Operator::Binary']
    , ['not in|in', 'DTL::Fast::Expression::Operator::Binary'] # not sure if priority is right
    , ['not', 'DTL::Fast::Expression::Operator::Unary']
    , ['defined', 'DTL::Fast::Expression::Operator::Unary']
    , ['[*]{2}', 'DTL::Fast::Expression::Operator::Binary']
]; # 

our %KNOWN;

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
        croak "Unknown operator '$operator'";
    }
    
    return $result;
}


1;