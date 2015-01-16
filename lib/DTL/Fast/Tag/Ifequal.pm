package DTL::Fast::Tag::Ifequal;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Tag::If';

$DTL::Fast::TAG_HANDLERS{'ifequal'} = __PACKAGE__;

use DTL::Fast::Tag::If::Condition;
use DTL::Fast::Expression::Operator::Binary::Eq;

#@Override
sub get_close_tag{ return 'endifequal';}

#@Override
sub parse_parameters
{
    my $self = shift;

    $self->{'conditions'} = [];
    my $sources = $self->parse_sources($self->{'parameter'});
    return $self->add_main_condition($sources);
}

#@Override
sub parse_tag_chunk
{
    my $self = shift;
    my $tag_name = shift;
    my $tag_param = shift;
    
    my $result = undef;

    if( $tag_name eq 'else' )
    {
        $self->add_condition(1);
    }
    else
    {
        $result = $self->SUPER::parse_tag_chunk($tag_name, $tag_param);
    }
    
    return $result;
}

#@Override
sub render
{
    my $self = shift;
    my $context = shift;
    my $result = '';
    
    foreach my $condition (@{$self->{'conditions'}})
    {
        if( $condition->is_true($context) )
        {
            $result = $condition->render($context);
            last;
        }
    }
    return $result;
}

sub add_main_condition
{
    my $self = shift;
    my $sources = shift;
    return $self->add_condition(DTL::Fast::Expression::Operator::Binary::Eq->new(@{$sources}[0,1]), '_template' => $self->{'_template'});
}

#@Override
sub add_condition
{
    my $self = shift;
    my $condition = shift;
    push @{$self->{'conditions'}}, DTL::Fast::Tag::If::Condition->new($condition, '_template' => $self->{'_template'});
    return $self;
}

1;