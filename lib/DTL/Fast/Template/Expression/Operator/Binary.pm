package DTL::Fast::Template::Expression::Operator::Binary;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Expression::Operator';

sub new
{
    my $proto = shift;
    my $operator = shift;
    my $argument1 = shift;
    my $argument2 = shift;

    my $self = $proto->SUPER::new($operator);
    
    $self->{'a'} = $argument1;
    $self->{'b'} = $argument2;
    
    return $self;
}

sub render
{
    my $self = shift;
    my $context = shift;
    
    die 'Rendering not yet implemented';
}

1;