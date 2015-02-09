package DTL::Fast::Tag::Warn;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Tag::Simple';  

use DTL::Fast::Template;
use Data::Dumper;
$DTL::Fast::TAG_HANDLERS{'warn'} = __PACKAGE__;

#@Override
sub parse_parameters
{
    my $self = shift;
    
    if ( $self->{'parameter'} )
    {
        $self->{'warn_names'} = [ split /\s+/, $self->{'parameter'}];
    }
    else
    {
        $self->{'warn_context'} = 1;
    }
    
    return $self;
}

sub render
{
    my($self,$context) = @_;
    if ( $self->{'warn_context'} )
    {
        warn "Current context dump: ".Dumper($context->{'ns'}->[-1]);
    }
    else
    {
        foreach my $var_name (@{$self->{'warn_names'}})
        {
            warn "Context variable `$var_name`: ".Dumper($context->get($var_name));
        }
    }    
}

1;
