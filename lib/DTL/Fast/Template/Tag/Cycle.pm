package DTL::Fast::Template::Tag::Cycle;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Tag::Simple';  

$DTL::Fast::Template::TAG_HANDLERS{'cycle'} = __PACKAGE__;

#@Override
sub parse_parameters
{
    my $self = shift;
    
    $self->{'parameter'} =~ /^\s*(.+?)\s*(?:as (.+?)\s*(silent)?)?\s*$/;
    @{$self}{'source', 'destination', 'silent', 'sources', 'current_sources'} = ($1 // '', $2 // '', $3 // '', [], []);
    $self->{'sources'} = $self->parse_sources($self->{'source'});
    
    return $self;
}

#@Override
sub render
{
    my $self = shift;
    my $context = shift;
    my $result = '';
  
    my $source = $self->get_next_source();
    my $current_value = $source->render($context);
  
    if( not $self->{'silent'} )
    {
        $result = $current_value;
        
        if( 
            not $context->get('_dtl_safe') 
            and not $source->{'filter_manager'}->{'safe'}
        )
        {
            $result = DTL::Fast::Utils::html_protect($result);
        }
    }
    
    if( $self->{'destination'} )
    {
        $context->set( $self->{'destination'} => $current_value );
    }
  
    return $result;
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

1;