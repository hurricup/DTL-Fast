package DTL::Fast::Template::Tag::Include;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Tag';

$DTL::Fast::Template::TAG_HANDLERS{'include'} = __PACKAGE__;

use DTL::Fast::Context;
use DTL::Fast::Template::Variable;

sub new
{
    my $proto = shift;
    my $parameter = shift;  # parameter of the opening tag
    my $template = shift;
    
    die "No template passed to the tag ".__PACKAGE__
        if ref $template ne 'DTL::Fast::Template';

    # parent class just blesses passed hash with proto. Nothing more. Use it
    # for future compatibility
    return $proto->SUPER::new(
    {
        'parent' => $template
        , 'template' => DTL::Fast::Template::Variable->new($parameter)
    });    
}

# Processing function
# @todo: recursion protection
sub render
{
    my $self = shift;
    my $context = shift // DTL::Fast::Context->new();
    
    my $result = DTL::Fast::get_template(
        $self->{'template'}->render($context)
        , $self->{'parent'}->{'dirs'}
    );
    
    return $result->render($context);
}

1;