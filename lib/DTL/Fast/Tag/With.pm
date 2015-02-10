package DTL::Fast::Tag::With;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Tag';  

$DTL::Fast::TAG_HANDLERS{'with'} = __PACKAGE__;

#@Override
sub get_close_tag{return 'endwith';}

#@Override
sub parse_parameters
{
    my $self = shift;

    $self->{'mappings'} = {};
    if( $self->{'parameter'} =~ /^\s*(.+?)\s+as\s+(.+)\s*$/s )  # legacy
    {
        $self->{'mappings'}->{$2} = DTL::Fast::Expression->new($1, '_template' => $self->{'_template'});
    }
    else    # modern
    {
        my @parts = split /[=\s]+/s, $self->backup_strings($self->{'parameter'});
        
        die sprintf("Unable to parse parameter for %s: %s", __PACKAGE__, $self->{'parameter'})
            if (scalar @parts) % 2;
        
        while( scalar @parts )
        {
            my $key = shift @parts;
            my $val = shift @parts;

            $self->{'mappings'}->{$key} = $self->get_backup_or_variable($val);
        }
    }
    
    return $self;
}

#@Override
sub render
{
    my $self = shift;
    my $context = shift;
    
    my %vars = ();
    foreach my $key (keys(%{$self->{'mappings'}}))
    {
        $vars{$key} = $self->{'mappings'}->{$key}->render($context);
    }
    
    $context->push_scope()->set(%vars);
   
    my $result = $self->SUPER::render($context);

    $context->pop_scope();
        
    return $result;
}

1;