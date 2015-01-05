package DTL::Fast::Template::Tag::If::Condition;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Renderer';
# this is a simple condition

sub new
{
    my $proto = shift;
    my $condition = shift;
    my %kwargs = @_;

    $kwargs{'condition'} = ref $condition ?
        $condition
        : DTL::Fast::Template::Expression->new($condition);
    
    return $proto->SUPER::new(%kwargs);
}

sub is_true
{
    my $self = shift;
    my $context = shift;
    return $self->{'condition'}->render($context);
}

1;