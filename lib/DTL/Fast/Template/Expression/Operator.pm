package DTL::Fast::Template::Expression::Operator;
use strict; use utf8; use warnings FATAL => 'all'; 

use DTL::Fast::Template::Expression::Operator::Unary;
use DTL::Fast::Template::Expression::Operator::Binary;

our $OPERATORS = [
    ['or', 'DTL::Fast::Template::Expression::Operator::Binary']
    , ['and', 'DTL::Fast::Template::Expression::Operator::Binary']
    , ['==|!=|<>|<=|>=|<|>', 'DTL::Fast::Template::Expression::Operator::Binary']
    , ['[+-]', 'DTL::Fast::Template::Expression::Operator::Binary']
    , ['[*/%]', 'DTL::Fast::Template::Expression::Operator::Binary']
    , ['not', 'DTL::Fast::Template::Expression::Operator::Unary']
    , ['[*]{2}', 'DTL::Fast::Template::Expression::Operator::Binary']
]; # 

sub new
{
    my $proto = shift;
    my $operator = shift;
    
    return bless{ 'op' => $operator }, $proto;
}

sub get_op
{
    return shift->{'op'};
}

1;