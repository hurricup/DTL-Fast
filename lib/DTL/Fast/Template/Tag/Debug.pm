package DTL::Fast::Template::Tag::Debug;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::SimpleTag';  
use Carp qw(confess);

$DTL::Fast::Template::TAG_HANDLERS{'debug'} = __PACKAGE__;

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
    
    my $self = $proto->SUPER::new( %kwargs );
    
    return $self;
}

# conditional rendering
sub render
{
    my $self = shift;
    my $context = shift;

    my $result = Dumper($context);
 
    return $result;
}

1;