package DTL::Fast::Expression::Operator::Binary;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Expression::Operator::Unary';
use Carp;

use DTL::Fast::Expression::Operator::Binary::Or;
use DTL::Fast::Expression::Operator::Binary::Plus;
use DTL::Fast::Expression::Operator::Binary::Minus;
use DTL::Fast::Expression::Operator::Binary::Eq;
use DTL::Fast::Expression::Operator::Binary::Ne;
use DTL::Fast::Expression::Operator::Binary::And;
use DTL::Fast::Expression::Operator::Binary::Ge;
use DTL::Fast::Expression::Operator::Binary::Le;
use DTL::Fast::Expression::Operator::Binary::Gt;
use DTL::Fast::Expression::Operator::Binary::Lt;
use DTL::Fast::Expression::Operator::Binary::Mul;
use DTL::Fast::Expression::Operator::Binary::Div;
use DTL::Fast::Expression::Operator::Binary::Pow;
use DTL::Fast::Expression::Operator::Binary::Mod;
use DTL::Fast::Expression::Operator::Binary::In;
use DTL::Fast::Expression::Operator::Binary::NotIn;

sub new
{
    my( $proto, $argument1, $argument2, %kwargs ) = @_;
    $kwargs{'b'} = $argument2;
    
    my $self = $proto->SUPER::new($argument1, %kwargs);
    
    return $self;
}

sub render_b
{
    return shift->{'b'}->render(shift);
}

sub render
{
    my( $self, $context ) = @_;
    
    return $self->dispatch(     # this is bad in or, cause second argument should be calculated only if first is false. But in our situation it doesn't matter
        $self->render_a($context)
        , $self->render_b($context) 
        , $context
    );
}

sub dispatch
{
    my( $self, $arg1, $arg2 ) = @_;
    croak  'ABSTRACT: This method should be overriden in subclasses';
}

1;