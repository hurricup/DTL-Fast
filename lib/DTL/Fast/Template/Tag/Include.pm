package DTL::Fast::Template::Tag::Include;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Tag::Simple';

$DTL::Fast::Template::TAG_HANDLERS{'include'} = __PACKAGE__;

use DTL::Fast::Template::Expression;

#@Override
sub parse_parameters
{
    my $self = shift;
    $self->{'template'} = DTL::Fast::Template::Expression->new($self->{'parameter'});
    return $self;
}

#@Override
# @todo: recursion protection
sub render
{
    my $self = shift;
    my $context = shift;
    
    my $template_name = $self->{'template'}->render($context);
    my $result = DTL::Fast::get_template(
        $template_name
        , $self->{'dirs'}
    );
  
    die sprintf(
        "Couldn't find included template %s in directories %s"
        , $template_name
        , join(', ', @{$self->{'dirs'}})
    ) if not defined $result;
  
    return $result->render($context);
}

1;