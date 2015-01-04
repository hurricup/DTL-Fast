package DTL::Fast::Template::Expression::Operator::Unary::Defined;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Expression::Operator::Unary';

$DTL::Fast::Template::Expression::Operator::KNOWN{'defined'} = __PACKAGE__;

use DTL::Fast::Utils qw(has_method);

sub render
{
    my( $self, $context) = @_;
    my $result = undef;

    
    if( $self->{'a'}->{'undef'} )
    {
        $result = 1;
    }
    else
    {
        $result = defined $self->render_a($context);
    }
    
    return $result;
}

1;