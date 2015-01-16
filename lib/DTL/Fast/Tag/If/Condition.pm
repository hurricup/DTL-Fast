package DTL::Fast::Tag::If::Condition;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Renderer';
# this is a simple condition

sub new
{
    my $proto = shift;
    my $condition = shift;
    my %kwargs = @_;

    $kwargs{'condition'} = ref $condition ?
        $condition
        : DTL::Fast::Expression->new($condition, '_template' => $kwargs{'_template'});
    
    my $self = $proto->SUPER::new(%kwargs);
    
    delete $self->{'_template'};
    
    return $self;
}

sub is_true
{
    my $self = shift;
    my $context = shift;
    return $self->{'condition'}->render_bool($context);
}

1;