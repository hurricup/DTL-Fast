package DTL::Fast::Expression::Operator::Unary::Logical;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Expression::Operator::Unary';

sub render_a
{
    return shift->{'a'}->render_bool(shift);
}

sub render_bool
{ 
    my( $self, @args ) = @_;
    return $self->render(@args); 
}

1;