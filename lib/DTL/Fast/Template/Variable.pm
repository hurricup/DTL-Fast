package DTL::Fast::Template::Variable;
use strict; use utf8; use warnings FATAL => 'all'; 
use Carp qw(confess);

use Scalar::Util qw(looks_like_number);

sub new
{
    my $proto = shift;
    my $variable = shift;

    $variable =~ s/(^\s+|\s+$)//gsi;
    my @filters = split /\|+/, $variable;
    
    my $variable_name = shift @filters;
    
    my @variable;
    my $static = 0;
    my $sign = 1;
    
    if( $variable_name =~ s/^\-// )
    {
        $sign = -1;
    }
    
    if( 
        $variable_name =~ /^\"(.+?)\"$/ 
    )   
    {
        @variable = ($1);
        $static = 1;
    }
    elsif( looks_like_number($variable_name) )
    {
        @variable = ($variable_name);
        $static = 1;
    }
    else
    {
        confess "Variable can't contain brackets: $variable_name" 
            if $variable_name =~ /[()]/;
        @variable = split /\.+/, $variable_name;
    }
    
    foreach my $filter (@filters)
    {
        my @arguments = split ':', $filter;
        my $filter_name = shift @arguments;

        if( exists $DTL::Fast::Template::FILTER_HANDLERS{$filter_name} )
        {
            $filter = $DTL::Fast::Template::FILTER_HANDLERS{$filter_name}->new(\@arguments);
        }
        else
        {
            warn "Unknown filter: $filter_name.";
            $filter = undef;
        }
    }
    
    return bless {
        'variable' => [@variable]
        , 'filters' => [@filters]
        , 'sign' => $sign
        , 'static' => $static
    }, $proto;
}

sub render
{
    my $self = shift;
    my $context = shift;
    
    my $value = $self->{'static'} ? 
        $self->{'variable'}->[0]
        : $context->get($self->{'variable'});
    
    foreach my $filter (@{$self->{'filters'}})
    {
        $value = $filter->filter($value, $context)
            if defined $filter;
    }
    
    return $value;
}

1;