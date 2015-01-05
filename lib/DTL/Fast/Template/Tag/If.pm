package DTL::Fast::Template::Tag::If;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Tag';

$DTL::Fast::Template::TAG_HANDLERS{'if'} = __PACKAGE__;

use DTL::Fast::Template::Tag::If::Condition;

#@Override
sub get_close_tag{ return 'endif';}

#@Override
sub parse_parameters
{
    my $self = shift;

    $self->{'conditions'} = [];
    $self->add_condition($self->{'parameter'});
    
    return $self;
}

#@Override
sub add_chunk
{
    my $self = shift;
    my $chunk = shift;
    
    $self->{'conditions'}->[-1]->add_chunk($chunk);
    return $self;
}

#@Override
sub parse_tag_chunk
{
    my $self = shift;
    my $tag_name = shift;
    my $tag_param = shift;
    
    my $result = undef;

    if( $tag_name eq 'elif' or $tag_name eq 'elsif' )
    {
        $self->add_condition($tag_param);
    }
    elsif( $tag_name eq 'else' )
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

sub add_condition
{
    my $self = shift;
    my $condition = shift;
    push @{$self->{'conditions'}}, DTL::Fast::Template::Tag::If::Condition->new($condition);
}

1;