package DTL::Fast::Tag::Include;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Tag::Simple';

$DTL::Fast::TAG_HANDLERS{'include'} = __PACKAGE__;

use DTL::Fast::Expression;

#@Override
sub parse_parameters
{
    my $self = shift;
    $self->{'template'} = DTL::Fast::Expression->new($self->{'parameter'}, '_template' => $self->{'_template'});
    return $self;
}

#@Override
sub render
{
    my $self = shift;
    my $context = shift;
    
    my $template_name = $self->{'template'}->render($context);
    
    my $result = DTL::Fast::get_template(
        $template_name
        , 'dirs' => $self->{'dirs'}
    );
  
    die sprintf(
        "Couldn't find included template %s in directories %s"
        , $template_name
        , join(', ', @{$self->{'dirs'}})
    ) if not defined $result;
  
    return $result->render($context);
}

1;