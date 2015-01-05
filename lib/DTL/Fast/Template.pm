package DTL::Fast::Template;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Parser';

our $UTF8 = 1;

our %TAG_HANDLERS;
our %FILTER_HANDLERS;
    
use DTL::Fast::Utils qw(has_method);
use DTL::Fast::Template::Variable;
use DTL::Fast::Template::Text;
use DTL::Fast::Template::Tags;
use DTL::Fast::Template::Filters;
    
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

    my $reg = qr/(\{[\{\%] .+? [\}\%]\})/;
    my $result = [split /$reg/s, $template];
    
    return $result;    
}

1;