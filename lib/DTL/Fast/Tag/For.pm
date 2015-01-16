package DTL::Fast::Tag::For;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Tag';
use Carp qw(confess);

$DTL::Fast::TAG_HANDLERS{'for'} = __PACKAGE__;

use DTL::Fast::Utils qw(has_method);
use DTL::Fast::Variable;

#@Override
sub get_close_tag{ return 'endfor';}

#@Override
sub parse_parameters
{
    my $self = shift;
    
    my(@target_names, $source_name, $reversed);
    if( $self->{'parameter'} =~ /^\s*(.+)\s+in\s+(.+?)\s*(reversed)?\s*$/si )
    {
        $source_name = $2;
        $reversed = $3;
        @target_names = map{
            confess "Iterator variable can't be traversable: $_" if $_ =~ /\./;
            $_;
        } split( /\s*,\s*/, $1 );
    }
    else
    {
        confess "Do not understand condition: $self->{'parameter'}";
    }
    
    $self->{'renderers'} = [];
    $self->add_renderer();

    $self->{'targets'} = [@target_names];

    $self->{'source'} = DTL::Fast::Variable->new($source_name);
    
    if( $reversed )
    {
        $self->{'source'}->add_filter('reverse');
    }
    
    if( not scalar @{$self->{'targets'}} )
    {
        confess "There is no target variables defined for iteration";
    }
    
    return $self;
}

#@Override
sub add_chunk
{
    my $self = shift;
    my $chunk = shift;
    
    $self->{'renderers'}->[-1]->add_chunk($chunk);
    return $self;
}

#@Override
sub parse_tag_chunk
{
    my $self = shift;
    my $tag_name = shift;
    my $tag_param = shift;
    
    my $result = undef;

    if( $tag_name eq 'empty' )
    {
        if( scalar @{$self->{'renderers'}} == 2 )
        {
            confess "There can be only one empty block";
        }
        else
        {
            $self->add_renderer;
        }
    }
    else
    {
        $result = $self->SUPER::parse_tag_chunk($tag_name, $tag_param);
    }
    
    return $result;
}

#@Override
sub render
{
    my $self = shift;
    my $context = shift;
    my $result = '';
  
    my $source_data = $self->{'source'}->render($context);
    my $source_type = ref $source_data;
    
    if( # iterating array
        $source_type eq 'ARRAY' 
        or (
            has_method($source_data, 'as_array')
            and ($source_data = $source_data->as_array($context))
        )
    )
    {
        $result = $self->render_array(
            $context
            , $source_data 
        );
    }
    elsif( # iterating hash
        $source_type eq 'HASH' 
        or (
            has_method($source_data, 'as_hash')
            and ($source_data = $source_data->as_hash($context))
        )
    )
    {
        $result = $self->render_hash(
            $context
            , $source_data
        );
    }
    else
    {
        confess sprintf('Do not know how to iterate %s (%s)'
            , $source_data
            , $source_type
        );
    }
    
    return $result;
}

sub render_array
{
    my $self = shift;
    my $context = shift;
    my $source_data = shift;

    my $result = '';

    if( scalar @$source_data )
    {
        $context->push();
        
        my $source_size = scalar @$source_data;
        my $forloop = $self->get_forloop($context, $source_size);
        
        $context->set('forloop' => $forloop);
        
        my $variables_number = scalar @{$self->{'targets'}};
        
        foreach my $value (@$source_data)
        {
            my $value_type = ref $value;
            if( $variables_number == 1 )
            {
                $context->set(
                    $self->{'targets'}->[0] => $value,
                );
            }
            else
            {
                if( 
                    $value_type eq 'ARRAY' 
                    or (
                        has_method($value, 'as_array')
                        and ($value = $value->as_array($context))
                    )
                )
                {
                    if( scalar @$value >= $variables_number )
                    {
                        my @argument = ();
                        for( my $i = 0; $i < $variables_number; $i++ )
                        {
                            push @argument
                                , $self->{'targets'}->[$i]
                                , $value->[$i]
                            ;
                        }
                        $context->set(@argument);
                    }
                    else
                    {
                        confess sprintf(
                            'Sub-array (%s) contains less items than variables number (%s)'
                            , join(', ', @$value)
                            , join(', ', @{$self->{'targets'}})
                        );
                    }
                }
                else
                {
                    confess "Multi-var iteration argument $value ($value_type) is not an ARRAY and has no as_array method";
                }
            }
            $result .= $self->{'renderers'}->[0]->render($context) // '';

            $self->step_forloop($forloop);
        }
        
        $context->pop();
    }
    elsif( scalar @{$self->{'renderers'}} == 2 ) # there is an empty block
    {
        $result = $self->{'renderers'}->[1]->render($context);
    }

    
    return $result;
}

sub render_hash
{
    my $self = shift;
    my $context = shift;
    my $source_data = shift;

    my $result = '';

    my @keys = keys %$source_data;
    my $source_size = scalar @keys;
    if( $source_size ) 
    {
        if( scalar @{$self->{'targets'}} == 2 )
        {
            $context->push();
            my $forloop = $self->get_forloop($context, $source_size);
            $context->set('forloop' => $forloop);
          
            foreach my $key (@keys)
            {
                my $val = $source_data->{$key};
                $context->set(
                    $self->{'targets'}->[0] => $key,
                    $self->{'targets'}->[1] => $val,
                );
                $result .= $self->{'renderers'}->[0]->render($context) // '';
                
                $self->step_forloop($forloop);
            }
            
            $context->pop();
        }
        else
        {
            confess "Hash can be only iterated with 2 target variables";
        }
    }
    elsif( scalar @{$self->{'renderers'}} == 2 ) # there is an empty block
    {
        $result = $self->{'renderers'}->[1]->render($context);
    }
    
    return $result;
}

sub add_renderer
{
    my $self = shift;
    push @{$self->{'renderers'}}, DTL::Fast::Renderer->new();
    return $self;
}

sub get_forloop
{
    my $self = shift;
    my $context = shift;
    my $source_size = shift;
    
    return {
        'parentloop' => $context->get('forloop')
        , 'counter' => 1
        , 'counter0' => 0
        , 'revcounter' => $source_size
        , 'revcounter0' => $source_size-1
        , 'first' => 1
        , 'last' => 0
        , 'length' => $source_size
        , 'odd' => 1
        , 'odd0' => 0
        , 'even' => 0
        , 'even0' => 1
    };
}

sub step_forloop
{
    my $self = shift;
    my $forloop = shift;
    
    $forloop->{'counter'}++;
    $forloop->{'counter0'}++;
    $forloop->{'revcounter'}--;
    $forloop->{'revcounter0'}--;
    $forloop->{'odd'} = $forloop->{'odd'} ? 0: 1;
    $forloop->{'odd0'} = $forloop->{'odd0'} ? 0: 1;
    $forloop->{'even'} = $forloop->{'even'} ? 0: 1;
    $forloop->{'even0'} = $forloop->{'even0'} ? 0: 1;
    $forloop->{'first'} = 0;
    if( $forloop->{'counter'} == $forloop->{'length'} )
    {
        $forloop->{'last'} = 1;
    }
}

1;