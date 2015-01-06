package DTL::Fast::Template;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Parser';
use Carp qw(confess);

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
    
    my $self = $proto->SUPER::new(%kwargs);
  
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
        confess "Context must be a DTL::Fast::Context object or a HASH reference";
    }
    
    $context->push();
    
    $context->set('_dtl_ssi_dirs' => $self->{'ssi_dirs'}) if $self->{'ssi_dirs'};
    $context->set('_dtl_url_source' => $self->{'url_source'}) if $self->{'url_source'};
    
    my $result = $self->SUPER::render($context);
    $context->pop();
    
    return $result;
}

1;