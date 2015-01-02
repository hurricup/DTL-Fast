package DTL::Fast::Template::Tag::For;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::BlockTag';  
use Carp qw(confess);

$DTL::Fast::Template::TAG_HANDLERS{'for'} = __PACKAGE__;

use DTL::Fast::Context;
use DTL::Fast::Template::Expression;
use DTL::Fast::Utils qw(has_method);

# atm gets arguments: 
# parameter - opening tag params
# named:
#   dirs: arrayref of template directories
#   raw_chunks: current raw chunks queue
sub new
{
    my $proto = shift;
    my $condition = shift;  # parameter of the opening tag
    my %kwargs = @_;
    
    my(@target_names, $source_name, $reversed);
    if( $condition =~ /^\s*(.+)\s+in\s+(.+)\s*(reversed)?\s*$/si )
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
        confess "Do not understand condition: $condition";
    }
    
    # parent class just blesses passed hash with proto. Nothing more. 
    # Use it for future compatibility
    my $self = $proto->SUPER::new( 
        $kwargs{'raw_chunks'}
        , $kwargs{'dirs'}
        , 'renderers' => [
            DTL::Fast::Template::Renderer->new()
        ]
        , 'source' => DTL::Fast::Template::Variable->new($source_name)
        , 'targets' => [@target_names]
    );    

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

# add chunk to the last condition
sub add_chunk
{
    my $self = shift;
    my $chunk = shift;
    
    $self->{'renderers'}->[-1]->add_chunk($chunk);
}

# parse extra tags from if blocks
sub parse_tag_chunk
{
    my $self = shift;
    my $tag_name = shift;
    my $tag_param = shift;
    
    my $result = undef;

    if( $tag_name eq 'endfor' )
    {
        $self->{'raw_chunks'} = [];
    }
    elsif( $tag_name eq 'empty' )
    {
        if( scalar @{$self->{'renderers'}} == 2 )
        {
            confess "There can be only one empty block";
        }
        else
        {
            push @{$self->{'renderers'}}, DTL::Fast::Template::Renderer->new();
        }
    }
    else
    {
        $result = $self->SUPER::parse_tag_chunk($tag_name, $tag_param);
    }
    
    return $result;
}

# conditional rendering
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
        if( scalar @$source_data )
        {
            $context->push();
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
            }
            
            $context->pop();
        }
        elsif( scalar @{$self->{'renderers'}} == 2 ) # there is an empty block
        {
            $result = $self->{'renderers'}->[1]->render($context);
        }
    }
    elsif( # iterating hash
        $source_type eq 'HASH' 
        or (
            has_method($source_data, 'as_hash')
            and ($source_data = $source_data->as_hash($context))
        )
    )
    {
        if( scalar (my @keys = keys %$source_data )) 
        {
            if( scalar @{$self->{'targets'}} == 2 )
            {
                $context->push();
                
                foreach my $key (@keys)
                {
                    my $val = $source_data->{$key};
                    $context->set(
                        $self->{'targets'}->[0] => $key,
                        $self->{'targets'}->[1] => $val,
                    );
                    $result .= $self->{'renderers'}->[0]->render($context) // '';
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

1;