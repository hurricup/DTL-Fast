package DTL::Fast::Template::Tag::Filter;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::BlockTag';  
use Carp qw(confess);

$DTL::Fast::Template::TAG_HANDLERS{'filter'} = __PACKAGE__;

use DTL::Fast::Template::FilterManager;

use Data::Dumper;

# atm gets arguments: 
# parameter - opening tag params
# named:
#   dirs: arrayref of template directories
#   raw_chunks: current raw chunks queue
sub new
{
    my $proto = shift;
    my $parameter = shift;  # parameter of the opening tag
    my %kwargs = @_;

    $kwargs{'filter_manager'} = DTL::Fast::Template::FilterManager->new($parameter);
    $kwargs{'close_tag'} = 'endfilter';
    
    my $self = $proto->SUPER::new( %kwargs );
    
    return $self;
}

sub filter_manager{ return shift->{'filter_manager'}; }


# conditional rendering
sub render
{
    my $self = shift;
    my $context = shift;
    my $result = '';

    return $self->filter_manager->filter(
        $self->SUPER::render($context)
        , $context
    );
}


1;