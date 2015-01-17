package DTL::Fast::Expression::Operator::Binary::Logical;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Expression::Operator::Binary';

sub render_a
{
    return shift->{'a'}->render_bool(shift);
}
sub render_b
{
    return shift->{'b'}->render_bool(shift);
}

sub render_bool{ 
    my( $self, @params ) = @_;
    return $self->render(@params); 
}

1;