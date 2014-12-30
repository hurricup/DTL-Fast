package DTL::Fast::Template::Expression::Operator;
use strict; use utf8; use warnings FATAL => 'all'; 

our $PRIORITY = [
    'or'
    , 'and'
    , '[=!<>]=?'
    , '[+-]'
    , '[*/]'
    , 'not'
];

our $OPERANDS = {
    'or' => {'left' => 1, 'right' => 1}
    , 'and' => {'left' => 1, 'right' => 1}
    , '[=!<>]=?' => {'left' => 1, 'right' => 1}
    , '[+-]' => {'left' => 1, 'right' => 1}
    , '[*/]' => {'left' => 1, 'right' => 1}
    , 'not' => {'right' => 1}
};

sub new
{
    my $proto = shift;
    my $operator = shift;
    
    return bless{ 'operator' => $operator }, $proto;
}

sub op
{
    return shift->{'operator'};
}

1;