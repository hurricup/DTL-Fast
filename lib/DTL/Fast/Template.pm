package DTL::Fast::Template;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Parser';
use Carp;

our %TAG_HANDLERS;
our %FILTER_HANDLERS;

use DTL::Fast::Context;
use DTL::Fast::Template::Tags;
use DTL::Fast::Template::Filters;    

#@Override
sub new
{
    my $proto = shift;
    my $template = shift // '';
    my $dirs = shift // []; # optional dirs to look up for includes or parents
    my %kwargs = @_;
    
    $kwargs{'raw_chunks'} = _get_raw_chunks($template);
    $kwargs{'dirs'} = $dirs;
    $kwargs{'file_path'} //= 'inline';
    $kwargs{'blocks'} = {};
    
    my $self = $proto->SUPER::new(%kwargs);
  
    return $self;
}

sub add_block
{
    my $self = shift;
    my $block_name = shift;
    my $block_ref = shift;
    
    if( exists $self->{'blocks'}->{$block_name} )
    {
        croak "Block $block_name is already registered. Duplicate names are not allowed";
    }
    
    $self->{'blocks'}->{$block_name} = $block_ref;
    
    return $self;
}

sub merge_blocks
{
    my $self = shift;
    my $donor = shift;

    foreach my $block_name ( keys %{$donor->{'blocks'}})
    {
        if( $self->{'blocks'}->{$block_name} )
        {
            $self->{'blocks'}->{$block_name}->{'chunks'} = $donor->{'blocks'}->{$block_name}->{'chunks'};
        }
    }
    
    return $self;
}

sub _get_raw_chunks
{
    my $template = shift;

    my $reg = qr/(
        \{\# .*? \#\}
        |\{\% .+? \%\}
        |\{\{ .+? \}\}
    )/x;
    my $result = [split /$reg/s, $template];
    
    return $result;    
}

#@Override
sub render
{
    my $self = shift;
    my $context = shift;

    $context //= {};
    
    if( ref $context eq 'HASH' )
    {
        $context = DTL::Fast::Context->new($context);
    }
    elsif( 
        defined $context 
        and ref $context ne 'DTL::Fast::Context'
    )
    {
        croak  "Context must be a DTL::Fast::Context object or a HASH reference";
    }
    
    $context->push();
    
    $context->{'ns'}->[-1]->{'_dtl_ssi_dirs'} = $self->{'ssi_dirs'} if $self->{'ssi_dirs'};
    $context->{'ns'}->[-1]->{'_dtl_url_source'} = $self->{'url_source'} if $self->{'url_source'};

    my $template_path = $self->{'file_path'};

    if( not exists $context->{'ns'}->[-1]->{'_dtl_include_path'} )  # entry point
    {
        $context->{'ns'}->[-1]->{'_dtl_include_path'} = [];
        $context->{'ns'}->[-1]->{'_dtl_include_files'} = {};
    }
    else    # check for recursion
    {
        if( exists $context->{'ns'}->[-1]->{'_dtl_include_files'}->{$template_path} )
        {
            # recursive inclusion
            die sprintf("Recursive inclusion detected:\n%s\n"
                , join( "\n includes ", @{$context->{'ns'}->[-1]->{'_dtl_include_path'}}, $template_path)
            );
        }
    }
    
    $context->{'ns'}->[-1]->{'_dtl_include_files'}->{$template_path} = 1;
    push @{$context->{'ns'}->[-1]->{'_dtl_include_path'}}, $template_path;
  
    my $result = $self->SUPER::render($context);
    
    pop @{$context->{'ns'}->[-1]->{'_dtl_include_path'}};
    delete $context->{'ns'}->[-1]->{'_dtl_include_files'}->{$template_path};
    
    $context->pop();
    
    return $result;
}

1;