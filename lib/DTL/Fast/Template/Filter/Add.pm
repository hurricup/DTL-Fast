package DTL::Fast::Template::Filter::Add;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter';
use Carp qw(confess);

$DTL::Fast::Template::FILTER_HANDLERS{'add'} = __PACKAGE__;

use DTL::Fast::Context;
use DTL::Fast::Template::Variable;
use Scalar::Util qw(looks_like_number);

sub new
{
    my $proto = shift;
    my $arguments = shift;  # this is a single argument. Arrayref with filter arguments splitted by /:/
    
    confess "No single arguments passed to the add ".__PACKAGE__
        if(
            ref $arguments ne 'ARRAY'
            or not scalar @$arguments
        );

    # parent class just blesses passed hash with proto. Nothing more. Use it
    # for future compatibility
    return $proto->SUPER::new(
        'arguments' => [(
            map{
                DTL::Fast::Template::Variable->new($_)
            } @$arguments
        )]
    );    
}

# filtering function
sub filter
{
    my $self = shift;
    my $value = shift;
    my $context = shift // DTL::Fast::Context->new();
    
    my $result = $value;
    my $value_type = ref $value;
    
    if( $value_type eq 'HASH' )
    {
        $result = {%$value};
    }
    elsif( $value_type eq 'ARRAY' )
    {
        $result = [@$value];
    }
    elsif( $value_type ) # @todo here we can implement ->add interface
    {
        confess "Don't know how to add anything to $value_type";
    }
    
    foreach my $argument (@{$self->{'arguments'}})
    {
        $argument = $argument->render($context);
        
        my $result_type = ref $result;
        my $argument_type = ref $argument;
        
        if( $result_type eq 'HASH' )
        {
            if( $argument_type eq 'ARRAY' )
            {
                %$result = (%$result, @$argument);
            }
            elsif( $argument_type eq 'HASH' )
            {
                %$result = (%$result, %$argument);
            }
            else
            {
                confess "It's not possible to add a single value to a hash";
            }
        }
        elsif( $result_type eq 'ARRAY' )
        {
            if( $argument_type eq 'ARRAY' )
            {
                push @$result, @$argument;
            }
            elsif( $argument_type eq 'HASH' )
            {
                push @$result, (%$argument);
            }
            else
            {
                push @$result, $argument;
            }
        }
        elsif( looks_like_number($result) and looks_like_number($argument) )
        {
            $result += $argument;
        }
        else
        {
            $result .= $argument;
        }        
    }
    
    return $result;
}

1;