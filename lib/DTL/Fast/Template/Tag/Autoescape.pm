package DTL::Fast::Template::Tag::Autoescape;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::BlockTag';  
use Carp qw(confess cluck);

$DTL::Fast::Template::TAG_HANDLERS{'autoescape'} = __PACKAGE__;

use DTL::Fast::Context;
use DTL::Fast::Template::Expression;

# atm gets arguments: 
# parameter - opening tag params
# named:
#   dirs: arrayref of template directories
#   raw_chunks: current raw chunks queue
sub new
{
    my $proto = shift;
    my $condition = shift;  # parameter of the opening tag
    my %kwargs = @_;

    my $safe = 0;
    if( $condition eq 'on' )
    {
        $kwargs{'safe'} = 0;
    }
    elsif( $condition eq 'off' )
    {
        $kwargs{'safe'} = 1;
    }
    else
    {
        confess "Autoescape tag undertands only on and off parameter";
    }

    $kwargs{'close_tag'} = 'endautoescape';
    
    # parent class just blesses passed hash with proto. Nothing more. 
    # Use it for future compatibility
    my $self = $proto->SUPER::new( 
        $kwargs{'raw_chunks'}
        , $kwargs{'dirs'}
        , %kwargs
    );    
    
    return $self;
}

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