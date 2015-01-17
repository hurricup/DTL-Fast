package DTL::Fast::Expression::Operator::Unary;
use strict; use utf8; use warnings FATAL => 'all'; 
use Carp;
use DTL::Fast::Utils qw(as_bool);

use DTL::Fast::Expression::Operator::Unary::Not;

# not in Django
use DTL::Fast::Expression::Operator::Unary::Defined;

sub new
{
    my( $proto, $argument, %kwargs ) = @_;
    $kwargs{'a'} = $argument;
    $kwargs{'_template'}->{'modules'}->{$proto} //= $proto->VERSION // $DTL::Fast::VERSION;

    delete $kwargs{'_template'};
    
    return bless {%kwargs}, $proto;
}

sub render_a
{
    return shift->{'a'}->render(shift);
}

sub render
{
    my( $self, $context ) = @_;

    return $self->dispatch( $self->render_a($context), $context );
}

sub render_bool
{
    return as_bool(shift->render(shift));
}

sub dispatch
{
    my( $self, $arg1 ) = @_;
    croak 'ABSTRACT: This method should be overriden in subclasses';
}
1;