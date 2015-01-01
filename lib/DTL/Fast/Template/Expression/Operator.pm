package DTL::Fast::Template::Expression::Operator;
use strict; use utf8; use warnings FATAL => 'all'; 

our $OPERATORS = [
    ['or', 'DTL::Fast::Template::Expression::Operator::Binary']
    , ['and', 'DTL::Fast::Template::Expression::Operator::Binary']
    , ['==|!=|<>|<=|>=|<|>', 'DTL::Fast::Template::Expression::Operator::Binary']
    , ['[+-]', 'DTL::Fast::Template::Expression::Operator::Binary']
    , ['[*/%]', 'DTL::Fast::Template::Expression::Operator::Binary']
    , ['not', 'DTL::Fast::Template::Expression::Operator::Unary']
    , ['[*]{2}', 'DTL::Fast::Template::Expression::Operator::Binary']
]; # 

our %KNOWN;

use DTL::Fast::Template::Expression::Operator::Unary;
use DTL::Fast::Template::Expression::Operator::Binary;

sub new
{
    my $proto = shift;
    my $operator = lc(shift);
    my $result = undef;
    
    if( $DTL::Fast::Template::Expression::Operator::KNOWN{$operator} )
    {
        $result = $DTL::Fast::Template::Expression::Operator::KNOWN{$operator}->new(@_);
    }
    else
    {
        die "Unknown operator '$operator'";
    }
    
    return $result;
}


1;