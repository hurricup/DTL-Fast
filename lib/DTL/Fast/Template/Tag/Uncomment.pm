package DTL::Fast::Template::Tag::Uncomment;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::BlockTag';  
use Carp qw(confess);

$DTL::Fast::Template::TAG_HANDLERS{'uncomment'} = __PACKAGE__;

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

    $kwargs{'close_tag'} = 'enduncomment';
    # parent class just blesses passed hash with proto. Nothing more. 
    # Use it for future compatibility
    my $self = $proto->SUPER::new( %kwargs );
    
    return $self;
}


1;