package DTL::Fast::Template;
use strict; use utf8; use warnings FATAL => 'all'; 
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

    my $self = bless {
        'dirs' => $dirs
        , 'chunks' => []
        , 'raw_chunks' => []
    }, $proto;

    $self->parse_template( $template );
    
    return $self;
}

sub render
{
    my $self = shift;
    my $context = shift;
    
    die "Context must be a DTL::Fast::Context object"
        if(
            defined $context
            and ref $context ne 'DTL::Fast::Context'
        );
        
    return join '', map{ 
        my $rendered = $_->render($context);
        ref $rendered ? ref $rendered: $rendered
    } @{$self->{'chunks'}};
}

sub parse_template
{
    my $self = shift;
    my $template = shift;

    my $reg = qr/(\{[\{\%] .+? [\}\%]\})/;
    $self->{'raw_chunks'} = [split /$reg/s, $template];
    
    while( scalar @{$self->{'raw_chunks'}} )
    {
        push @{$self->{'chunks'}}, $self->parse_next_chunk(shift @{$self->{'raw_chunks'}});
    }
}

sub parse_next_chunk
{
    my $self = shift;
    my $chunk = shift;
    
    if( $chunk =~ /^\{\{ (.+?) \}\}$/ )
    {
        $chunk = DTL::Fast::Template::Variable->new($1, $self );
    }
    elsif
    ( 
        $chunk =~ /^\{\% ([^\s]+?)(?: (.*?))? \%\}$/ 
    )
    {
        my($tag_name, $tag_param) = ($1, $2);
        
        if( exists $TAG_HANDLERS{$tag_name} )
        {        
            $chunk = $TAG_HANDLERS{$tag_name}->new($tag_param, $self);
        }
        else
        {
            warn "Unknown tag: $tag_name";
            $chunk = DTL::Fast::Template::Text->new( "", $self );
        }
    }
    else
    {
        $chunk = DTL::Fast::Template::Text->new( $chunk, $self );
    }
    
    return $chunk;
}

# argument parser
sub parse_argument
{
    my $self = shift;
    my $raw_argument = shift;
    
    $self->debug('Parsing argument %s') if $self->{'debug'};
    
    return $raw_argument;
}

1;