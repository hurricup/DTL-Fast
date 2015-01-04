package DTL::Fast::Template::Expression::Operator::Unary;
use strict; use utf8; use warnings FATAL => 'all'; 
use Carp qw(confess);

use DTL::Fast::Template::Expression::Operator::Unary::Not;

# not in Django
use DTL::Fast::Template::Expression::Operator::Unary::Defined;

sub new
{
    my $proto = shift;

    return bless { 'a' => shift }, $proto;
}

sub render_a
{
    return shift->{'a'}->render(shift);
}

sub render
{
    my $self = shift;
    my $context = shift;

    return $self->dispatch( $self->render_a($context), $context );
}

sub dispatch
{
    my $self = shift;
    my $arg1 = shift;
    confess 'ABSTRACT: This method should be overriden in subclasses';
}
1;