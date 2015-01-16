package DTL::Fast::Tag::Autoescape;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Tag';  
use Carp;

$DTL::Fast::TAG_HANDLERS{'autoescape'} = __PACKAGE__;

#@Override
sub get_close_tag{ return 'endautoescape';}

#@Override
sub parse_parameters
{
    my $self = shift;
    
    if( $self->{'parameter'} eq 'on' )
    {
        $self->{'safe'} = 0;
    }
    elsif( $self->{'parameter'} eq 'off' )
    {
        $self->{'safe'} = 1;
    }
    else
    {
        croak "Autoescape tag undertands only on and off parameter";
    }
    return $self;
}

#@Override
sub render
{
    my $self = shift;
    my $context = shift;

    $context->push()->set('_dtl_safe' => $self->{'safe'}); 
    my $result = $self->SUPER::render($context);
    $context->pop();
    
    return $result;
}

1;