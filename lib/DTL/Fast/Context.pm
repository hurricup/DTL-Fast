package DTL::Fast::Context;
use strict; use utf8; use warnings FATAL => 'all'; 
use Carp;

use DTL::Fast::Utils qw(has_method);

sub new
{
    my $proto = shift;
    my $context = shift // {};
    
    croak  "Context should be a HASH reference"
        if ref $context ne 'HASH';
        
    return bless {
        'ns' => [$context]
    }, $proto;
}

sub get
{
    my $self = shift;
    my $variable_path = shift;

    if( ref $variable_path ne 'ARRAY' )    # suppose that raw variable invoked, period separated
    {
        $variable_path = [split /\.+/, $variable_path];
    }
    else
    {
        $variable_path = [@$variable_path]; # cloning for re-use
    }
    
    my $variable_name = shift @$variable_path;
    
    # faster version
    my $namespace = $self->{'ns'}->[-1];
    my $variable = exists $namespace->{$variable_name} ? 
        $namespace->{$variable_name}
        : undef; 

    $variable = $variable->($self) 
        if ref $variable eq 'CODE';
        
    $variable = $self->traverse($variable, $variable_path)
        if 
            defined $variable 
            and scalar @$variable_path;

    return $variable;
}

# tracing variable path
sub traverse
{
    my $self = shift;
    my $variable = shift;
    my $path = shift;

    foreach my $step (@$path)
    {
        my $current_type = ref $variable;
        if( $current_type eq 'HASH' )
        {
            $variable = $variable->{$step};
        }
        elsif( 
            $current_type eq 'ARRAY'
            and $step =~ /^\-?\d+$/
        )
        {
            $variable = $variable->[$step];
        }
        elsif( has_method($variable, $step) )
        {
            $variable = $variable->$step($self);
        }
        else
        {
            croak  sprintf("Don't know how to traverse %s (%s) with %s"
                , $variable
                , $current_type
                , $step 
            );
        }        
    }
        
    $variable = $variable->($self) 
        if ref $variable eq 'CODE';

    return $variable;
}

sub set
{
    my $self = shift;
    my @sets = @_;
    
    while( 
        defined (my $key = shift @sets)
        and defined (my $val = shift @sets)
    )
    {
        if( $key =~ /\./ )  # traversed set
        {
            my @key = split /\.+/, $key;
            my $variable_name = pop @key;
            my $variable = $self->get([@key]);
            
            croak  sprintf('Unable to set variable %s because parent %s is not defined.'
                , $key
                , join('.', @key)
            ) if not defined $variable;

            my $variable_type = ref $variable;
            if( $variable_type eq 'HASH' )
            {
                $variable->{$variable_name} = $val;
            }
            elsif( 
                $variable_type eq 'ARRAY'
                and $variable_name =~ /^\-?\d+$/
            )
            {
                $variable->[$variable_name] = $val;
            }
            else
            {
                croak  sprintf("Don't know how to set variable %s for parent node of type %s"
                    , $variable_name
                    , $variable_type
                );
            }            
        }
        else
        {
            $self->{'ns'}->[-1]->{$key} = $val;
        }
    }
    return $self;
}

sub push
{
    my $self = shift;
#    push @{$self->{'ns'}}, {}; # multi-level version, suppose it's slower on reading
    push @{$self->{'ns'}}, {%{$self->{'ns'}->[-1] // {}}};
    return $self;
}

sub pop
{
    my $self = shift;
    croak  "It's a last context layer available."
        if scalar @{$self->{'ns'}} ==  1;
    pop @{$self->{'ns'}};
    return $self;
}

1;