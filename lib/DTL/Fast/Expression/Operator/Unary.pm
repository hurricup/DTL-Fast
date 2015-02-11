package DTL::Fast::Expression::Operator::Unary;
use strict; use utf8; use warnings FATAL => 'all'; 

use DTL::Fast::Template;

sub new
{
    my( $proto, $argument, %kwargs ) = @_;
    $kwargs{'a'} = $argument;
    $DTL::Fast::Template::CURRENT_TEMPLATE->{'modules'}->{$proto} //= $proto->VERSION // DTL::Fast->VERSION;
    
    return bless {%kwargs}, $proto;
}

sub render
{
    my( $self, $context) = @_;
    
    return $self->dispatch( 
        $self->{'a'}->render($context, 1)
        , $context 
    );
}

sub dispatch
{
    my( $self, $arg1 ) = @_;
    die 'ABSTRACT: This method should be overriden in subclasses';
}
1;