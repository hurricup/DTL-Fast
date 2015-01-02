package DTL::Fast::Template::Variable;
use strict; use utf8; use warnings FATAL => 'all'; 
use Carp qw(confess cluck);

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
    
    my $self = bless {
        'variable' => [@variable]
        , 'original' => $variable
        , 'filters' => []
        , 'sign' => $sign
        , 'static' => $static
        , 'safe' => 0       # suppresses escaping
    }, $proto;
    
    foreach my $filter (@filters)
    {
        $self->add_filter($filter);
    }

    return $self;
}

sub add_filter
{
    my $self = shift;
    my $filter = shift;

    if( $filter eq 'safe' )
    {
        $self->{'safe'} = 1;
    }
    else
    {
        my @arguments = split ':', $filter;
        my $filter_name = shift @arguments;

        if( exists $DTL::Fast::Template::FILTER_HANDLERS{$filter_name} )
        {
            push @{$self->{'filters'}}, $DTL::Fast::Template::FILTER_HANDLERS{$filter_name}->new(\@arguments);
        }
        else
        {
            warn "Unknown filter: $filter_name.";
        }
    }
}

sub render
{
    my $self = shift;
    my $context = shift;
    
    my $value = $self->{'static'} ? 
        $self->{'variable'}->[0]
        : $context->get($self->{'variable'});

    if( defined $value )
    {
        foreach my $filter (@{$self->{'filters'}})
        {
            $value = $filter->filter($value, $context)
                if defined $filter;
        }
    }
    else
    {
        # @todo make it clear how to behave on undef value and not existed key
        cluck sprintf('Variable %s does not exists in current context'
            , $self->{'original'}
        ) if not defined $value;
        $value = '';
    }
    
    return $value;
}

1;