package DTL::Fast::Context;
use strict; use utf8; use warnings FATAL => 'all'; 
use Carp qw(confess cluck);

use DTL::Fast::Utils qw(has_method);

sub new
{
    my $proto = shift;
    my $context = shift // {};
    
    confess "Context should be a HASH reference"
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
    
    my $namespace_index = $#{$self->{'ns'}};
    
    my $namespace = $self->{'ns'}->[$namespace_index];
    while(
        $namespace_index > 0
        and not exists $namespace->{$variable_name}
    )
    {
        $namespace = $self->{'ns'}->[--$namespace_index];
    }

    my $variable = exists $namespace->{$variable_name} ? 
        $namespace->{$variable_name}
        : undef;
        
    $variable = $self->traverse($variable, $variable_path)
        if( defined $variable );
        
    return $variable;
}

# tracing variable path
sub traverse
{
    my $self = shift;
    my $variable = shift;
    my $path = shift;
    
    $variable = $variable->($self) 
        if ref $variable eq 'CODE';

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
            confess sprintf("Don't know how to traverse %s (%s) with %s"
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
            
            confess sprintf('Unable to set variable %s because parent %s is not defined.'
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
                confess sprintf("Don't know how to set variable %s for parent node of type %s"
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
    push @{$self->{'ns'}}, {};
    return $self;
}

sub pop
{
    my $self = shift;
    confess "It's a last context layer available."
        if scalar @{$self->{'ns'}} ==  1;
    pop @{$self->{'ns'}};
    return $self;
}

1;