package DTL::Fast::Template::Variable;
use strict; use utf8; use warnings FATAL => 'all'; 
use Carp qw(confess cluck);

use Scalar::Util qw(looks_like_number);
use DTL::Fast::Template::FilterManager;

sub new
{
    my $proto = shift;
    my $variable = shift;
    my %kwargs = @_;
    
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
        , 'sign' => $sign
        , 'static' => $static
        , 'filter_manager' => DTL::Fast::Template::FilterManager->new()
    }, $proto;

    if( scalar @filters )
    {
        $self->filter_manager->add_filters(\@filters);
    }

    return $self;
}

sub filter_manager{ return shift->{'filter_manager'}; }
sub is_safe{ return shift->filter_manager->is_safe; }
sub add_filter{ return shift->filter_manager->add_filter(shift); }

sub render
{
    my $self = shift;
    my $context = shift;
    
    my $value = $self->{'static'} ? 
        $self->{'variable'}->[0]
        : $context->get($self->{'variable'});

    if( defined $value )
    {
        $value = $self->filter_manager->filter($value, $context);
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