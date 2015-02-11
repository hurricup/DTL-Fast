package DTL::Fast::Tag::If;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Tag';

$DTL::Fast::TAG_HANDLERS{'if'} = __PACKAGE__;

use DTL::Fast::Tag::If::Condition;

#@Override
sub get_close_tag{ return 'endif';}

#@Override
sub parse_parameters
{
    my( $self ) = @_;

    $self->{'conditions'} = [];
    $self->add_condition($self->{'parameter'});
    
    return $self;
}

#@Override
sub add_chunk
{
    my( $self, $chunk ) = @_;
    
    $self->{'conditions'}->[-1]->add_chunk($chunk);
    return $self;
}

#@Override
sub parse_tag_chunk
{
    my( $self, $tag_name, $tag_param ) = @_;
    
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
    my( $self, $context ) = @_;
    
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
    my( $self, $condition ) = @_;
    push @{$self->{'conditions'}}, DTL::Fast::Tag::If::Condition->new($condition);
    return $self;
}

1;