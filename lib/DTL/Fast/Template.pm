package DTL::Fast::Template;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Iterator';

our $UTF8 = 1;

our %TAG_HANDLERS;
our %FILTER_HANDLERS;
    
use DTL::Fast::Template::Variable;
use DTL::Fast::Template::Text;
use DTL::Fast::Template::Tags;
use DTL::Fast::Template::Filters;
    
sub new
{
    my $proto = shift;
    my $template = shift // '';
    my $dirs = shift // []; # optional dirs to look up for includes or parents

    my $self = $proto->SUPER::new(
        _get_raw_chunks($template)
        , $dirs
    );
    
    return $self;
}


sub _get_raw_chunks
{
    my $template = shift;
    
    my $reg = qr/(\{[\{\%] .+? [\}\%]\})/;
    return [split /$reg/s, $template];    
}


1;