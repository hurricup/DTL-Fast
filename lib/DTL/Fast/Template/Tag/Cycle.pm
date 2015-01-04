package DTL::Fast::Template::Tag::Cycle;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::SimpleTag';  
use Carp qw(confess);

$DTL::Fast::Template::TAG_HANDLERS{'cycle'} = __PACKAGE__;

use DTL::Fast::Context;
use DTL::Fast::Template::Expression;
use DTL::Fast::Utils qw(has_method);

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
    
    $parameter =~ /^\s*(.+?)\s*(?:as (.+?)\s*(silent)?)?\s*$/;
    @kwargs{'source', 'destination', 'silent', 'parameter', 'sources', 'current_sources'} = ($1 // '', $2 // '', $3 // '', $parameter, [], []);
    
    # parent class just blesses passed hash with proto. Nothing more. 
    # Use it for future compatibility
    my $self = $proto->SUPER::new( %kwargs );

    # parse source line
    $self->{'sources'} = $self->parse_sources($self->{'source'});
    
    return $self;
}

sub get_next_source
{
    my $self = shift;
    
    if( not scalar @{$self->{'current_sources'}} )    # populate for current cycle
    {
        push @{$self->{'current_sources'}}, @{$self->{'sources'}}; 
    }
    
    return shift @{$self->{'current_sources'}};
}

# conditional rendering
sub render
{
    my $self = shift;
    my $context = shift;
    my $result = '';
  
    my $current_value = $self->get_next_source()->render($context);
  
    if( not $self->{'silent'} )
    {
        $result = $current_value;
    }
    
    if( $self->{'destination'} )
    {
        $context->set( $self->{'destination'} => $current_value );
    }
  
    return $result;
}

1;