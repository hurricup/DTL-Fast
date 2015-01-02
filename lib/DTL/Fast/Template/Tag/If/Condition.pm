package DTL::Fast::Template::Tag::If::Condition;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Renderer';
# this is a simple condition

sub new
{
    my $proto = shift;
    my $condition = shift;
    
    return $proto->SUPER::new(
        'condition' => DTL::Fast::Template::Expression->new($condition)
    );
}

sub is_true
{
    my $self = shift;
    my $context = shift;
    return $self->{'condition'}->render($context);
}

1;