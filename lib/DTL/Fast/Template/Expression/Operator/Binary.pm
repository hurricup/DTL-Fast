package DTL::Fast::Template::Expression::Operator::Binary;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Expression::Operator::Unary';

use DTL::Fast::Template::Expression::Operator::Binary::Or;
use DTL::Fast::Template::Expression::Operator::Binary::Plus;
use DTL::Fast::Template::Expression::Operator::Binary::Minus;
use DTL::Fast::Template::Expression::Operator::Binary::Eq;
use DTL::Fast::Template::Expression::Operator::Binary::Ne;
use DTL::Fast::Template::Expression::Operator::Binary::And;
use DTL::Fast::Template::Expression::Operator::Binary::Ge;
use DTL::Fast::Template::Expression::Operator::Binary::Le;
use DTL::Fast::Template::Expression::Operator::Binary::Gt;
use DTL::Fast::Template::Expression::Operator::Binary::Lt;
use DTL::Fast::Template::Expression::Operator::Binary::Mul;
use DTL::Fast::Template::Expression::Operator::Binary::Div;
use DTL::Fast::Template::Expression::Operator::Binary::Pow;
use DTL::Fast::Template::Expression::Operator::Binary::Mod;

sub new
{
    my $proto = shift;
    my $argument1 = shift;
    my $argument2 = shift;

    my $self = $proto->SUPER::new($argument1);
    $self->{'b'} = $argument2;
    
    return $self;
}

sub render_b
{
    return shift->{'b'}->render(shift);
}

sub render
{
    my $self = shift;
    my $context = shift;
    
    return $self->dispatch(     # this is bad in or, cause second argument should be calculated only if first is false. But in our situation it doesn't matter
        $self->render_a($context)
        , $self->render_b($context) 
    );
}

sub dispatch
{
    my $self = shift;
    my $arg1 = shift;
    my $arg2 = shift;
    die 'ABSTRACT: This method should be overriden in subclasses';
}

1;