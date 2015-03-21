package DTL::Fast::Variable;
use strict; use utf8; use warnings FATAL => 'all'; 
no if $] >= 5.017011, warnings => 'experimental::smartmatch';

use Scalar::Util qw(looks_like_number);
use DTL::Fast::FilterManager;
use DTL::Fast::Utils qw(as_bool);
use DTL::Fast::Template;

sub new
{
    my( $proto, $variable, %kwargs ) = @_;
    
    $variable =~ s/(^\s+|\s+$)//gsi;
    my @filters = split /\s*\|+\s*/, $variable;
    
    my $variable_name = shift @filters;

    if( 
        $kwargs{'replacement'} 
        and my $replacement = $kwargs{'replacement'}->get_replacement($variable_name)
    )
    {
        $variable_name = $replacement->{'original'};    # got stored string
    }
    
    my @variable;
    my $static = 0;
    my $sign = 1;
    my $undef = 0;
    
    if( $variable_name =~ s/^\-// )
    {
        $sign = -1;
    }
    
    if( 
        $variable_name =~ /^(?<!\\)(["'])(.*?)(?<!\\)\1$/ 
    )   
    {
        @variable = ($2);
        $static = 1;
        $sign = 1;
    }
    elsif( 
        $variable_name eq 'undef'
        or $variable_name eq 'None' # python compatibility
    )
    {
        $static = 1;
        $sign = 1;
        $undef = 1;
        @variable = (undef);        
    }
    elsif( looks_like_number($variable_name) )
    {
        @variable = ($variable_name);
        $static = 1;
    }
    else
    {
        die "Variable can't contain brackets: $variable_name" 
            if $variable_name =~ /[()]/;
        @variable = split /\.+/, $variable_name;
    }
    
    my $self = bless {
        'variable' => [@variable]
        , 'original' => $variable
        , 'direct_read' => ( scalar @variable == 1 )
        , 'sign' => $sign
        , 'undef' => $undef
        , 'static' => $static
        , 'source_line' => $DTL::Fast::Template::CURRENT_TEMPLATE_LINE
        , 'filter_manager' => DTL::Fast::FilterManager->new('replacement' => $kwargs{'replacement'})
    }, $proto;

    if( scalar @filters )
    {
        $self->{'filter_manager'}->add_filters(\@filters);
    }

    return $self;
}

sub add_filter{ return shift->{'filter_manager'}->add_filter(shift); }

sub render
{
    my( $self, $context, $global_safe ) = @_;
    
    my $value = undef;
    
    if( not $self->{'undef'} )
    {
        $value = $self->{'static'} 
            ? $self->{'variable'}->[0]
            : $self->{'direct_read'}
                ? $context->{'ns'}->[-1]->{$self->{'variable'}->[0]}
                : $context->get($self->{'variable'});
                
        while (ref $value eq 'CODE')
        {
            $value = 'lvalue' ~~ attributes::get($value) ?
                $value->()
                : $value->($self);
        }
    }
    $value = $self->{'filter_manager'}->filter($value, $context)
        if $self->{'filter_manager'}->{'filters_number'};
    
    return (
        not $global_safe 
        and not $self->{'filter_manager'}->{'safe'}
    ) 
        ? DTL::Fast::html_protect($value)
        : $value;
}

our $BOOL_PROCESSORS = {
    'SCALAR' => sub
    { 
        my( $value ) = @_; 
        return $$value; 
    }
    , 'HASH' => sub
    { 
        my( $value ) = @_; 
        return scalar keys(%$value); 
    }
    , 'ARRAY' => sub
    { 
        my( $value ) = @_; 
        return scalar @$value; 
    }
};

1;