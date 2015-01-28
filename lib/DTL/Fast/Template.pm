package DTL::Fast::Template;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Parser';
use Carp;

our %TAG_HANDLERS;
our %FILTER_HANDLERS;

use DTL::Fast::Context;
use DTL::Fast::Tags;
use DTL::Fast::Filters;    

#@Override
sub new
{
    my( $proto, $template, %kwargs ) = @_;
    $template //= '';

    $kwargs{'raw_chunks'} = _get_raw_chunks($template);
    $kwargs{'dirs'} //= [];             # optional dirs to look up for includes or parents
    $kwargs{'file_path'} //= 'inline';  
    $kwargs{'inherits'} //= {};
    $kwargs{'inherited'} //= [];
    $kwargs{'perl'} = $];
    $kwargs{'modules'} //= {
        'DTL::Fast' => $DTL::Fast::VERSION,
    };

    if( exists $kwargs{'inherits'}->{$kwargs{'file_path'}} )
    {
        croak  sprintf(
            "Recursive inheritance detected:\n%s\n" 
            , join "\n inherited from ", @{$kwargs{'inherited'}}, $kwargs{'file_path'}
        );
    }
    
    $kwargs{'inherits'}->{$kwargs{'file_path'}} = $kwargs{'file_path'} eq 'inline' ? 
        0: # this should depend on calling script
        (stat($kwargs{'file_path'}))[9];
        
    push @{$kwargs{'inherited'}}, $kwargs{'file_path'};
    
    my $self = $proto->SUPER::new(%kwargs);

    if( $self->{'extends'} )
    {
        my $parent_template = DTL::Fast::read_template(
            $self->{'extends'}
            , %kwargs
        );
          
        if( defined $parent_template )
        {
            $self = $parent_template->merge_template($self);
        }
        else
        {
            croak  sprintf( "Couldn't found a parent template: %s in one of the following directories: %s"
                , $self->{'extends' }
                , join( ', ', @{$kwargs{'dirs'}})
            );
        }
    }
    
    return $self;
}

sub merge_template
{
    my( $self, $donor ) = @_;

    foreach my $block_name ( keys %{$donor->{'blocks'}})
    {
        if( my $block = $self->{'blocks'}->{$block_name} )
        {
            $block->replace_with($donor->{'blocks'}->{$block_name});
        }
    }

    # appending module dependencies
    my @modules = keys %{$donor->{'modules'}};
    @{$self->{'modules'}}{@modules} = @{$donor->{'modules'}}{@modules};
    
    # appending inheritance path
    @{$self}{'inherited','inherits'} = @{$donor}{'inherited','inherits'};
    
    return $self;
}

#@Override
sub get_container_block{ return shift; }

my $reg = qr/(
     \{\#.+?\#\}
    |\{\%.+?\%\}
    |\{\{.+?\}\}
)/xs;

sub _get_raw_chunks
{
    my( $template ) = @_;

    my $result = [split $reg, $template];
    
    return $result;    
}

#@Override
sub render
{
    my( $self, $context ) = @_;

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
    
    $context->push_scope();
    
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
    
    $context->pop_scope();
    
    return $result;
}

1;